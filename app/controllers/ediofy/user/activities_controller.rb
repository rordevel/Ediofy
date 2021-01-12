# TODO not using in BETA
class Ediofy::User::ActivitiesController < Ediofy::UserController
  def index
    @activities = @user.recent_activities.order("created_at desc").page params[:page]
    @questions = @user.questions.order("created_at desc").limit(3)
    @media = @user.media.order("created_at desc").limit(3)
    @collections = @user.user_collections.order("created_at desc").limit(3)
  end
end
