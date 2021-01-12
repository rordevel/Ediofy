class Ediofy::SearchController < EdiofyController
  include NewFilter

  def index
    @content_results, @content_total_results, @has_more_content = content_search
    @people_results, @people_total_results, @has_more_people = people_search
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
      search('content', options)
    end

    def people_search
      search('people')
    end

    def search(type, options = {})
      query = params[:q] || ''
      query = query.rstrip
      options[:query] = query.gsub(/'|`/, "'" => "`", "`" => "``").gsub(/[\s\'|:&()!]+/, '|')
      super(type, options)
    end
end
