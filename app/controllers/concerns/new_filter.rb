module NewFilter
  extend ActiveSupport::Concern
  protected

    def search(type, options = {})
      if options[:query].present? 
        options[:query] =  options[:query].gsub("&", '')
      end

      page = params[:page] || 1
      options[:limit] ||= 12
      options[:offset] = (page.to_i - 1) * options[:limit]

      options[:user_id] ||= current_user.id

      perform_search(type, options)     
      perform_popular_content_search(options) if type == 'content' && @total == 0
      
      search_results = @results.map do |result|
        type = result['_result_type']
        klass = type.classify.constantize
        attributes = JSON.parse(result[type])
        klass.instantiate(attributes)
      end

      has_more_results = (@total - (options[:offset] + search_results.count)) > 0

      [search_results, @total, has_more_results]
    end

    def perform_search(type, options)
      results_query = self.send("#{type}_search_results", options)
      @results = ActiveRecord::Base.connection.execute(results_query)

      total_query = self.send("#{type}_search_results_total", options)
      results_total = ActiveRecord::Base.connection.execute(total_query)
      @total = results_total.first['total']
    end

    def perform_popular_content_search(options)
      results_query = self.send("popular_content_search_results", options)
      @results = ActiveRecord::Base.connection.execute(results_query)

      total_query = self.send("popular_content_search_results_total", options)
      results_total = ActiveRecord::Base.connection.execute(total_query)
      @total = results_total.first['total']
    end

    def popular_content_search_results(options)
      order_column = 'comments_count'
          
      <<-SQL
        SELECT
          search_results.type AS _result_type,
          TO_JSON(conversations.*) AS conversations,
          TO_JSON(links.*) AS links,
          TO_JSON(media.*) AS media,
          TO_JSON(questions.*) AS questions
        FROM (#{popular_content_search_results_subquery(options[:user_id], options[:content_type])}) search_results
        LEFT JOIN conversations ON search_results.type = 'conversations' AND conversations.id = search_results.id
        LEFT JOIN links ON search_results.type = 'links' AND links.id = search_results.id
        LEFT JOIN media ON search_results.type = 'media' AND media.id = search_results.id
        LEFT JOIN questions ON search_results.type = 'questions' AND questions.id = search_results.id
        ORDER BY search_results.#{order_column} DESC
        LIMIT #{options[:limit]}
        OFFSET #{options[:offset]}
      SQL
    end

    def popular_content_search_results_total(options)
      <<-SQL
        SELECT COUNT(*) AS total
        FROM (#{popular_content_search_results_subquery(options[:user_id], options[:content_type])}) search_results
      SQL
    end

    def popular_content_search_results_subquery(user_id, type)
      from = if type.blank?
        <<-SQL
          (#{Conversation.popular_query(user_id)})
          UNION
          (#{Media.popular_query(user_id)})
          UNION
          (#{Question.popular_query(user_id)})
          UNION
          (#{Link.popular_query(user_id)})
        SQL
      elsif %w(audio image pdf video).include?(type)
        Media.popular_query(user_id, type)
      else
        model = type.classify.constantize
        model.popular_query(user_id)
      end
  
      <<-SQL
        SELECT id,
        type,
        TS_RANK_CD(textsearch, '') AS rank,
        created_at,
        cached_votes_up,
        comments_count,
        view_count
        FROM
          (#{from}) content_taggings
      SQL
    end

    def content_search_results(options)
      order_column = case options[:sort_by]
        when 'latest' then 'created_at'
        when 'top_rated' then 'cached_votes_up'
        when 'most_popular' then 'comments_count'
        when 'trending' then 'view_count'
      end
  
      <<-SQL
        SELECT
          search_results.type AS _result_type,
          TO_JSON(conversations.*) AS conversations,
          TO_JSON(links.*) AS links,
          TO_JSON(media.*) AS media,
          TO_JSON(questions.*) AS questions
        FROM (#{content_search_results_subquery(options[:query], options[:user_id], options[:content_type])}) search_results
        LEFT JOIN conversations ON search_results.type = 'conversations' AND conversations.id = search_results.id
        LEFT JOIN links ON search_results.type = 'links' AND links.id = search_results.id
        LEFT JOIN media ON search_results.type = 'media' AND media.id = search_results.id
        LEFT JOIN questions ON search_results.type = 'questions' AND questions.id = search_results.id
        ORDER BY search_results.#{order_column} DESC
        LIMIT #{options[:limit]}
        OFFSET #{options[:offset]}
      SQL
    end
  
    def content_search_results_total(options)
      <<-SQL
        SELECT COUNT(*) AS total
        FROM (#{content_search_results_subquery(options[:query], options[:user_id], options[:content_type])}) search_results
      SQL
    end
  
    def content_search_results_subquery(query, user_id, type)
      from = if type.blank?
        <<-SQL
          (#{Conversation.taggings_query(user_id)})
          UNION
          (#{Media.taggings_query(user_id)})
          UNION
          (#{Question.taggings_query(user_id)})
          UNION
          (#{Link.taggings_query(user_id)})
        SQL
      elsif %w(audio image pdf video).include?(type)
        Media.taggings_query(user_id, type)
      else
        model = type.classify.constantize
        model.taggings_query(user_id)
      end
  
      <<-SQL
        SELECT id,
        type,
        TS_RANK_CD(textsearch, query) AS rank,
        created_at,
        cached_votes_up,
        comments_count,
        view_count
        FROM
          (#{from}) content_taggings,
          TO_TSQUERY('#{query}') query
        WHERE textsearch @@ query
      SQL
    end

    def people_search_results(options)
      <<-SQL
        SELECT
          search_results.type AS _result_type,
          TO_JSON(groups.*) AS groups,
          TO_JSON(users.*) AS users
        FROM (#{people_search_results_subquery(options[:query], options[:user_id])}) search_results
        LEFT JOIN groups ON search_results.type = 'groups' AND groups.id = search_results.id
        LEFT JOIN users ON search_results.type = 'users' AND users.id = search_results.id
        ORDER BY search_results.created_at DESC
        LIMIT #{options[:limit]}
        OFFSET #{options[:offset]}
      SQL
    end

    def people_search_results_total(options)
      <<-SQL
        SELECT COUNT(*) AS total
        FROM (#{people_search_results_subquery(options[:query], options[:user_id])}) search_results
      SQL
    end

    def people_search_results_subquery(query, user_id)
      <<-SQL
        SELECT id,
        type,
        TS_RANK_CD(textsearch, query) AS rank,
        created_at
        FROM
          (
            (#{Group.taggings_query})
            UNION
            (#{User.taggings_query(user_id)})
          ) people_taggings,
          TO_TSQUERY('#{query}') query
        WHERE textsearch @@ query
      SQL
    end

    def user_tags
      @user_tags ||= current_user.taggings.map(&:tag).flatten.compact.map(&:name)
        .uniq
        .join('|')
        .gsub(/[\s\'|:&()!]+/, '|')
        .gsub("'", "''")
    end
end
