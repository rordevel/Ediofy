ActiveAdmin.register_page 'Ratings' do
  menu parent: 'Reports', priority: 0

  sidebar :filters do
    render partial: 'admin/shared/filter', locals: { filter_path: admin_ratings_path }
  end

  content do
    title = params[:q][:content_title] if params[:q].present?
    ratings = Vote.ratings(title)
    render partial: 'admin/rating', locals: { collection: ratings }
  end

  page_action :view, method: [:get] do
    if params[:type] && params[:type] == 'Question'
      @resource = Question.find_by(id: params[:id])
    elsif params[:type] && params[:type] == 'Media'
      @resource = Media.find_by(id: params[:id])
    end
  end
end
