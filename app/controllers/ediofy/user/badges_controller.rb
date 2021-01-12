# TODO not using in BETA
class Ediofy::User::BadgesController < Ediofy::UserController
  before_action :prepare_other_user, only: :compare

  protected

  def prepare_other_user
    @other_user = User.find params[:other_user_id]
  end
end
