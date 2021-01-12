module Ediofy::SearchHelper
  def content_type_dropdown
    select_tag(
      :content_type,
      options_for_select(
        {
          'All Content' => '',
          'Images' => :image,
          'Videos' => :video,
          'Audio' => :audio,
          'Questions' => :questions,
          'Conversations' => :conversations,
          'PDFs' => :pdf,
        },
        params[:content_type]
      ),
      id: nil,
      class: 'form-control select-down search-content-type'
    )
  end

  def sort_by_dropdown
    select_tag(
      :sort_by,
      options_for_select(
        {
          'Latest' => :latest,
          'Top Rated' => :top_rated,
          'Most Popular' => :most_popular,
          'Trending' => :trending
        },
        params[:sort_by]
      ),
      id: nil,
      class: 'form-control select-down search-sort-by',
    )
  end

  def link_to_next_results_page(action = 'index')
    filter_params = {
      controller: params[:controller],
      action: action,
      page: params[:page].present? ? params[:page].to_i + 1 : 2
    }
    filter_params[:q] = params[:q] if params[:q].present?
    filter_params[:content_type] = params[:content_type] if params[:content_type].present?
    filter_params[:sort_by] = params[:sort_by] if params[:sort_by].present?

    link_to 'Load more', url_for(filter_params), remote: true, class: 'btn button color-blue back-hov-clr'
  end
end
