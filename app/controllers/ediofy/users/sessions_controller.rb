class Ediofy::Users::SessionsController < Devise::SessionsController
  layout 'home', only: [:new]
  skip_before_action :ensure_on_boarding_process_completed

  def create
    email = params[:user][:email].downcase
    user = User.where(email: email).first
    if email == ''
      flash[:email_empty] = 'We do not recognise this email address'
    elsif !user
      flash[:invalid_email] = 'We do not recognise this email address'
    elsif user && !user.valid_password?(params[:user][:password])
      flash[:wrong_password] = 'The email address and/or password is incorrect'
    end
    super
  end
  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :user
      ediofy_root_path
      # new_user_session_path
    elsif resource_or_scope == :admin
      new_admin_user_session_path
    else
      root_path
    end
  end
end