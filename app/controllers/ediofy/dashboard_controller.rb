class Ediofy::DashboardController < EdiofyController
  include FilterResult
  include NewFilter

  def index
    params[:history_limit] = 4
    user_history
    @user_onboarding_state = check_user_onboarding_state

    @content_results, @content_total_results, @has_more_content = content_search
    @people_results, @people_total_results, @has_more_people = people_search

    respond_to do |format|
      format.html
      format.js
    end
  end

  def content
    @content_results, @content_total_results, @has_more_content = content_search
  end

  def people
    @people_results, @people_total_results, @has_more_people = people_search
  end

  private

    def content_search
      options = {}
      options[:sort_by] = params[:sort_by] || 'latest'
      options[:content_type] = params[:content_type].downcase if params[:content_type].present?
      options[:query] = user_tags

      search('content', options)
    end

    def people_search
      search('people', query: user_tags)
    end
end
