# TODO not using in Beta
class Ediofy::UniversitiesController < EdiofyController

  before_action :load_university, only: [:overview, :users, :questions, :media, :user_collections, :join, :leave]

  def index
    @query = params[:query] || ''
    @order_by = params[:order_by]
    @direction = params[:direction]

    @universities = University.advanced_search(
      query: @query,
      order_by: @order_by,
      direction: @direction
    )
    @universities = @universities.page params[:page]

    respond_with @universities
  end

  def show
    @university = University.find params[:id]
    redirect_to ediofy_university_overview_path(@university)
  end

  def overview
    @users = @university.users.with_ranks_this_week
    @recent_activities = @university.activities.order("created_at desc").page params[:recent_activities_page]
    @popular_questions = @university.questions.popular(6)
    @popular_media_collections = @university.media_collections.visible_to(current_user).popular(6)
    @popular_user_collections = @university.user_collections.order("created_at desc").limit(6)
    @new_users = @university.users.order("created_at desc").limit(6)
  end

  def join
    if current_user.present?
      current_user.university_group = @university
      current_user.save
      flash[:notice] = t 'flash.ediofy.universities.joined', university: @university.name
    end
    redirect_to ediofy_university_overview_path(@university)
  end

  def leave
    if current_user.present? && current_user.university_group.present? && current_user.university_group == @university
      current_user.university_group = nil
      current_user.save
      flash[:notice] = t 'flash.ediofy.universities.left', university: @university.name
    end
    redirect_to ediofy_university_overview_path(@university)
  end

  def users
    @users = @university.users.page params[:page]
  end

  def questions
    @questions = @university.questions.page params[:page]
  end

  def media
    @media_collections = @university.media_collections.visible_to(current_user).page params[:page]
  end

  def user_collections
    @user_collections = @university.user_collections.page params[:page]
  end

protected

  def load_university
    @university = University.find params[:university_id]
  end

end
