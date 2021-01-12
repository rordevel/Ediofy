class Ediofy::UserController < EdiofyController
  before_action :prepare_user

protected

  def prepare_user
    @user = User.find params[:user_id]
  end

end
