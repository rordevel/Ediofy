class Ediofy::RelatedController < EdiofyController
  def index
    page = params[:page] || 1
    per = 10
    content_type = params[:type].classify
    return_type = params[:return_type].classify
    
    # sql = related_content(params[:return_type], content_type, params[:id], current_user.id, per, (page.to_i - 1) * per)
    # total_sql = related_content_total(params[:return_type], content_type, params[:id], current_user.id)

    @media = @questions = @conversations = @links = []
    if content_type === "Media"
      currentMedia = Media.find(params[:id])
      tags =  currentMedia.tags.pluck("name")
    end


    if content_type === "Question"
      currentQuestion = Question.find(params[:id])
      tags =  currentQuestion.tags.pluck("name")
    end

    if content_type === "Conversation"
      currentConversation = Conversation.find(params[:id])
      tags =  currentConversation.tags.pluck("name")
    end

    if content_type === "Link"
      currentLink = Link.find(params[:id])
      tags =  currentLink.tags.pluck("name")
    end

  allMedia = Media.tagged_with(tags, :any => true) - [currentMedia]
  allQuestions = Question.tagged_with(tags, :any => true) - [currentQuestion]
  allConversations = Conversation.tagged_with(tags, :any => true) - [currentConversation]
  allLinks = Link.tagged_with(tags, :any => true) - [currentLink]


    
  #subtracting content that is in non-joined groups 

   private_media = []
    allMedia.each do |m|
      mediaGroups = m.groups
      mediaGroups.each do |mg|
        unless mg.in_group?(current_user)
          private_media << m
        end
      end
    end


    private_questions = []
    allQuestions.each do |q|
      questionGroups = m.groups
      questionGroups.each do |qg|
        unless qg.in_group?(current_user)
          private_questions << q
        end
      end
    end

    private_conversations = []
    allConversations.each do |c|
      conversationGroups = c.groups
      conversationGroups.each do |cg|
        unless cg.in_group?(current_user)
          private_conversations << q
        end
      end
    end

    private_questions = []
    allQuestions.each do |q|
      questionGroups = m.groups
      questionGroups.each do |qg|
        unless qg.in_group?(current_user)
          private_questions << q
        end
      end
    end
    
    private_links = []
    allLinks.each do |l|
      linkGroups = l.groups
      linkGroups.each do |lg|
        unless lg.in_group?(current_user)
          private_links << q
        end
      end
    end
    
   
    @media = allMedia - private_media  || [] if return_type === "Media"
    @questions = allQuestions - private_questions || [] if return_type === "Question"
    @conversations = allConversations - private_conversations || [] if return_type === "Conversations"
    @links = allLinks - private_links  || [] if return_type === "Link"
   
    @all = @media + @conversations + @questions + @links
    @total = @media.count + @conversations.count + @questions.count + @links.count

    @related_contents = Kaminari.paginate_array(@all.to_a, total_count:   @total).page(page).per(per)

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def related_content(type, content_type, content_id, user_id, limit, offset)
      <<-SQL
        #{related_content_subquery(type, content_type, content_id, user_id)}
        ORDER BY rank DESC
        LIMIT #{limit}
        OFFSET #{offset};
      SQL
    end

    def related_content_total(type, content_type, content_id, user_id)
      <<-SQL
        SELECT COUNT(*) AS total
        FROM (#{related_content_subquery(type, content_type, content_id, user_id)}) related_content
      SQL
    end

    def related_content_subquery(type, content_type, content_id, user_id)
      if type == 'media'
        content_taggings_subquery = <<-SQL
          (#{Link.taggings_query(user_id)})
          UNION
          (#{Media.taggings_query(user_id)})
        SQL
      else
        klass = type.classify.constantize
        content_taggings_subquery = klass.send(:taggings_query, user_id)
      end

      <<-SQL
        SELECT id, type, TS_RANK_CD(textsearch, query) AS rank
        FROM (#{content_taggings_subquery}) content_taggings, (#{content_tags(content_type, content_id)}) content_tags, TO_TSQUERY(content_tags.tags) query
        WHERE textsearch @@ query
        AND ('#{content_type.pluralize.downcase}' != '#{type}' OR id != #{content_id})
      SQL
    end

    def content_tags(content_type, content_id)
      <<-SQL
        SELECT REPLACE(COALESCE(STRING_AGG(REGEXP_REPLACE(t.name, ' ', '|'), '|'), ''), '''', '''''') AS tags
        FROM taggings tg
        LEFT JOIN tags t ON t.id = tg.tag_id
        WHERE tg.taggable_type = '#{content_type}'
          AND tg.taggable_id = #{content_id}
          AND tg.context = 'tags'
      SQL
    end
end
