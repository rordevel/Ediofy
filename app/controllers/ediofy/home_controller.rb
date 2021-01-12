class Ediofy::HomeController < EdiofyController
  skip_before_action :authenticate_user!
  layout 'home', only: [:show]
  def user_signin
    email = params[:user][:email].downcase
    @user = User.where(email: email).first
    if email == ''
      flash[:email_empty] = 'We do not recognise this email address'
    elsif !@user
      flash[:invalid_email] = 'We do not recognise this email address'
    elsif @user && !@user.valid_password?(params[:user][:password])
      flash[:wrong_password] = 'The email address and/or password is incorrect'
    elsif !@user.blank?
      sign_in @user
      @after_sign_path = after_sign_in_path_for(@user)
    end
  end
end
