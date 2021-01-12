# TODO not using in BETA
class Ediofy::User::UserCollectionsController < Ediofy::UserController
  
  def index
    @user_collections = @user.user_collections.visible_to(current_user).page params[:page]
  end

end