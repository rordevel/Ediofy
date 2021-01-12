# frozen_string_literal: true

module FilterResult
  extend ActiveSupport::Concern

  included do
    helper_method :search_and_filter, :sort_results, :sorted_results, :total_sorted_results, :content_type, :search_and_filter_follow
  end

  def search_and_filter
    #constructing the params for the store procedure queries
    unfollowed_user_ids = unfollowed
    user_tags = userTags
    p_params_total = ""

    search_query_string = params[:q] || ""
    page = params[:page] || 1
    limit = 12
    offset = (page.to_i - 1) * limit
    storedProcedureParams = "p_limit := #{limit}, p_offset := #{offset},p_blocked_ids := '#{unfollowed_user_ids}',p_following_ids := '#{following_ids}',p_sort := '#{sort_by}', p_tags := '#{user_tags}'"

    if search_query_string.length > 2
        search_query_string = search_query_string.gsub(' ','&').gsub("'", "\\'")

        storedProcedureParams += ", p_search := '#{search_query_string}'"
        p_params_total = "p_search := '#{search_query_string}'"
    else
      params[:history_limit] = 4
      user_history
    end


    contributors unless params[:only_content] == true
    return unless params[:b_ediofy_dashboard_index_people_sort].blank?

      resultsQuery = getResultQuery(storedProcedureParams, search_query_string, content_type, unfollowed_user_ids, alluser_ids, user_tags)
      totalQuery =  getCountQuery(storedProcedureParams, search_query_string, content_type, unfollowed_user_ids, alluser_ids, user_tags)

      #SQL Results


      results = results.nil? ? ActiveRecord::Base.connection.execute(resultsQuery) : results
      results_total = results_total.nil? ? ActiveRecord::Base.connection.execute(totalQuery) : results_total

      @search_results = Kaminari.paginate_array(results.to_a, total_count:results.values.count).page(page).per(limit)

      fetch_results  
  end

  def sort_results
    @users = sorted_results('User') if content_type == 'contributors' || content_type.blank?
    @conversations = sorted_results('Conversation')  if content_type == 'conversations' || content_type.blank?
    @media = sorted_results('Media') if content_type == 'media' || content_type.blank?
    @questions = sorted_results('Question') if content_type == 'questions' || content_type.blank?
    @links = sorted_results('Link') if content_type == 'links' || content_type.blank?
  end

  def fetch_results

    @search_results.group_by { |r| r['type'] }.each do |type, v|
      classReference = type.capitalize.singularize.constantize

      ids = v.map { |f| f['id'] }
        if (type != nil)
          result = classReference.unscoped.where(id: ids)
          @conversations = result if type == 'conversations'
          @media = result if type == 'media'
          @links = result if type == 'links'
          @questions = result if type == 'questions'
          @groups = result if type == 'groups' || type == 'group'
        end
    end
  end


  def sorted_results(type)
    return if type.blank?
    table_name = type.pluralize.downcase
    klass = type.capitalize.constantize
    return klass.joins("LEFT JOIN votes ON #{table_name}.id = votes.votable_id AND votable_type = '#{type.capitalize}'").select("COUNT(votes.votable_id) AS vote_count, #{table_name}.* ").group("#{table_name}.id").order('vote_count desc') if params[:sort_by] == 'top_rated'
    return klass.joins("LEFT JOIN comments ON #{table_name}.id = comments.commentable_id  AND commentable_type = '#{type.capitalize}'").select("COUNT(comments.commentable_id) AS comment_count, #{table_name}.* ").group("#{table_name}.id").order('comment_count desc') if params[:sort_by] == 'most_popular'
    return klass.order('view_count desc') if params[:sort_by] == 'trending'

    klass.order('created_at desc')
  end

  def total_sorted_results
    all = @users.to_a + @conversations.to_a + @media.to_a + @questions.to_a + @links.to_a
    return all.sort_by(&:vote_count).reverse if %w[top_rated].include? sort_by
    return all.sort_by(&:comment_count).reverse if %w[most_popular].include? sort_by
    return all.sort_by(&:view_count).reverse if params[:sort_by] == 'trending'

    all.sort_by(&:created_at).reverse
  end

  def content_type
    if request.path.include?('conversations')
      params[:content_type] = 'conversations'
    elsif params[:content_type].blank?
      params[:content_type] = ''
    else
      params[:content_type].downcase
    end
  end



 def getResultQuery(p_params, query, content_type, unfollowed_user_ids, alluser_ids, user_tags)
        if content_type == 'contributors'
          sql = "SELECT * FROM users_search_results(#{p_params})"
        elsif %w[conversations media questions links video audio image pdf].include? content_type
          p_params_total = "p_search := '#{query}'," 
          p_params_total += "p_blocked_ids := '#{unfollowed_user_ids}',p_following_ids := '#{following_ids}', p_tags := '#{user_tags}'"
          sql = "SELECT * FROM #{content_type}_search_results(#{p_params})"
        else
            p_params_total = "p_search := '#{query}'," 
            p_params_total += "p_blocked_ids := '#{unfollowed_user_ids}',p_following_ids := '#{alluser_ids}', p_tags := '#{user_tags}'"
            sql = "SELECT * FROM search_results(#{p_params})"
        end
      end

       def getCountQuery(p_params, query, content_type, unfollowed_user_ids, alluser_ids, user_tags)
        if content_type == 'contributors'
          total_sql = "SELECT * FROM users_search_results_total(#{p_params_total})"
        elsif %w[conversations media questions links video audio image pdf].include? content_type
          p_params_total = "p_search := '#{query}'," 
          p_params_total += "p_blocked_ids := '#{unfollowed_user_ids}',p_following_ids := '#{following_ids}', p_tags := '#{user_tags}'"
          total_sql = "SELECT * FROM #{content_type}_search_results_total(#{p_params_total})"
        else
            p_params_total = "p_search := '#{query}'," 
            p_params_total += "p_blocked_ids := '#{unfollowed_user_ids}',p_following_ids := '#{alluser_ids}', p_tags := '#{user_tags}'"
            total_sql = "SELECT * FROM search_results_total(#{p_params_total})"
        end
      end

      def userTags
         current_user.taggings.map(&:tag)
                        .flatten.compact.map(&:name)
                        .uniq.join('|').tr(' ', '|').gsub("'", "''")
      end

      def allTags
          all_Tags =  Tag.all.pluck(:name).uniq.join("|").gsub(" ","|").gsub("'","''").gsub(",", "|")
      end

      def unfollowed
         current_user.blocks.pluck(:id).join(',').to_s
      end





  def sort_by
    return params[:b_ediofy_dashboard_index_people_sort] unless params[:b_ediofy_dashboard_index_people_sort].blank?

    params[:sort_by].blank? ? 'latest' : params[:sort_by]
  end

  def user_history
    page = params[:page] || 1
    per = params[:history_limit] || 12
    # ViewedHistory.left_joins(:conversations, :links, :media, :questions)
    if content_type == 'conversations'
      result = ViewedHistory.joins("JOIN conversations ON viewed_histories.viewable_id = conversations.id AND viewed_histories.viewable_type='Conversation'
                                    LEFT JOIN users uc ON conversations.user_id = uc.id
                                  ").where('uc.is_active=true')
    elsif %w[audio video image pdf media].include?(content_type)
      result = media_history
    elsif content_type == 'questions'
      result = ViewedHistory.joins("JOIN questions ON viewed_histories.viewable_id = questions.id AND viewed_histories.viewable_type='Question'
                                    LEFT JOIN users uq ON questions.user_id = uq.id
                                  ").where('uq.is_active=true')
    elsif content_type == 'links'
      result = ViewedHistory.joins("JOIN links ON viewed_histories.viewable_id = links.id AND links.viewable_type='Link'
                                    LEFT JOIN users ul ON links.user_id = ul.id
                                  ").where('ul.is_active=true')
    else
      result = ViewedHistory.joins("LEFT JOIN links ON viewed_histories.viewable_id = links.id AND viewed_histories.viewable_type='Link'
      LEFT JOIN conversations ON viewed_histories.viewable_id = conversations.id AND viewed_histories.viewable_type='Conversation'
      LEFT JOIN media ON viewed_histories.viewable_id = media.id AND viewed_histories.viewable_type='Media'
      LEFT JOIN questions ON viewed_histories.viewable_id = questions.id AND viewed_histories.viewable_type='Question'
      LEFT JOIN users uq ON questions.user_id = uq.id
      LEFT JOIN users ul ON links.user_id = ul.id
      LEFT JOIN users um ON media.user_id = um.id
      LEFT JOIN users uc ON conversations.user_id = uc.id
      ").where('uq.is_active=true OR ul.is_active=true OR um.is_active=true OR uc.is_active=true')
    end
    result = result.where('viewed_histories.user_id = ?', @user ? @user.id : current_user.id).where.not('viewed_histories.viewable_type = ?', 'User')
    result = user_history_order(result)
    @histories_total = result.count
    @search_results = @histories = Kaminari.paginate_array(result.to_a, total_count: @total).page(page).per(per)
  end

  def media_history
    if content_type == 'media'
      ViewedHistory.joins("JOIN media ON viewed_histories.viewable_id = media.id AND viewed_histories.viewable_type='Media'
                                   LEFT JOIN users um ON media.user_id = um.id
                                 ").where('um.is_active=true')
    else
      ViewedHistory.joins("JOIN media ON viewed_histories.viewable_id = media.id AND viewed_histories.viewable_type='Media'
         JOIN media_files ON media_files.media_id = media.id AND media_files.media_type='#{content_type}'
                           LEFT JOIN users um ON media.user_id = um.id
                         ").where('um.is_active=true')
    end
  end

  def user_history_order(result)
    type = %w[audio video image pdf].include?(content_type) ? 'media' : content_type
    result = if sort_by == 'top_rated' && !type.blank?
               result.order("#{type}.cached_votes_up desc")
             elsif sort_by == 'most_popular' && !type.blank?
               result.order("#{type}.comments_count desc")
             elsif sort_by == 'trending' && !type.blank?
               result.order("#{type}.view_count desc")
             else
               result.order('viewed_histories.updated_at desc')
             end
    result
  end

  def user_contributions
    page = params[:page] || 1
    per = 12
    p_profile = current_user != @user
    p_params = "p_limit := #{per}, p_offset := #{(page.to_i - 1) * per}, p_user_id := #{@user.id}, p_profile := #{p_profile}, p_sort := '#{sort_by}'"
    p_params_total = "p_user_id := #{@user.id}, p_profile := #{p_profile}"

    if %w[conversations media questions links image audio video pdf].include? content_type
      sql = "SELECT * FROM user_contributions_#{content_type}(#{p_params})"
      total_sql = "SELECT * FROM user_contributions_#{content_type}_total(#{p_params_total})"
    else
      sql = "SELECT * FROM user_contributions(#{p_params})"
      total_sql = "SELECT * FROM user_contributions_total(#{p_params_total})"
    end
    results_total = ActiveRecord::Base.connection.execute(total_sql)
    if results_total.to_a.blank?
      @total = 0
    else
      results = ActiveRecord::Base.connection.execute(sql)
      @total = results_total.first['total']
      @search_results = Kaminari.paginate_array(results.to_a, total_count: @total).page(page).per(per)
      fetch_results
    end
  end

  def search_and_filter_follow

    page = params[:page] || 1
    per = params[:follow_per_page] || 21
    p_params = "p_limit := #{per}, p_offset := #{(page.to_i - 1) * per}, p_sort := '#{sort_by}'"
    p_params += " ,p_user_id := #{current_user.id}" # unless params[:filter_for_user] == false
    p_params_total = "p_user_id := #{current_user.id}"
    type = params[:follow_type].blank? ? 'all' : params[:follow_type].downcase

    if type == 'suggested'
      sql = "SELECT * FROM users_follows_suggested(#{p_params})"
      total_sql = "SELECT * FROM users_follows_suggested_total(#{p_params_total})"

      results = ActiveRecord::Base.connection.execute(sql)
      results_total = ActiveRecord::Base.connection.execute(total_sql)
      @total = results_total.first['total']
      @follows = Kaminari.paginate_array(results.to_a, total_count: @total).page(page).per(per)
      # @follows = Kaminari.paginate_array(current_user.all_following.to_a, total_count: @total).page(page).per(per)
      @users = User.where(id: @follows.collect { |u| u['id'] })

    elsif type == 'mine'
      sql = "SELECT * FROM users_follows_my(#{p_params})"
      total_sql = "SELECT * FROM users_follows_my_total(#{p_params_total})"
      results = ActiveRecord::Base.connection.execute(sql)
      results_total = ActiveRecord::Base.connection.execute(total_sql)
      @total = results_total.first['total']
      # little hack
      results = current_user.all_following.to_a if type == 'mine'
      @follows = Kaminari.paginate_array(results.to_a, total_count: @total).page(page).per(per)
      # @follows = Kaminari.paginate_array(current_user.all_following.to_a, total_count: @total).page(page).per(per)
      @users = User.where(id: @follows.collect { |u| u['id'] })

    else # all
      @users = User.all_active.where.not(id: current_user)
      @follows = Kaminari.paginate_array(@users.to_a, total_count: @users.count).page(page).per(per)
    end















  end

  def contributors
    params[:follow_per_page] = 7
    # search_and_filter_follow
    page = params[:page] || 1
    per = 7
    p_params = "p_limit := #{per}, p_offset := #{(page.to_i - 1) * per}, p_sort := '#{sort_by}'"
    p_params_total = ''
    @tags = []

    if !params[:q].blank? && params[:q].length > 2
      # :* is for partial match
      search = "#{params[:q].split(',').collect(&:strip).join('&').gsub(/[^0-9A-Za-z. ]/, '').tr(' ', '&')}:*"
      p_params += ", p_search := '#{search}'"
      p_params_total += "p_search := '#{search}'"
      sql = "SELECT * FROM users_search_results(#{p_params})"
      total_sql = "SELECT * FROM users_search_results_total(#{p_params_total})"
      results = ActiveRecord::Base.connection.execute(sql)
      results_total = ActiveRecord::Base.connection.execute(total_sql)
      @total = results_total.first['total']
      @follows = Kaminari.paginate_array(results.to_a, total_count: @total).page(page).per(per)
    else
      @total = 0
      @follows = []
    end
    @users = User.where(id: @follows.collect { |u| u['id'] })
  end

  def following_ids
    if current_user.following_users.count.positive?
      "#{current_user.following_users.pluck(:id).join(',')},#{current_user.id}"
    else
      current_user.id
    end
  end

  # for populating the learn section when users sign in for the first time..
  def alluser_ids
    "#{User.all.pluck(:id).join(',')},#{current_user.id}"
  end
end
