class Ediofy::Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def failure
    Rails.logger.error "#{env["omniauth.error"]}: #{env['omniauth.error'].response.inspect if env['omniauth.error'].respond_to? :response}"
    super
  end
  def twitter
    omniauth
  end

  def facebook
    omniauth
  end

  def google
    omniauth
  end

  def linkedin
    omniauth
  end
protected

  def auth
    request.env['omniauth.auth']
  end

  def omniauth
    if user_signed_in?
      already_user = User.find_for_omniauth auth

      if already_user.present? and already_user != current_user
        flash[:alert] = flash_t :already_connected
      else
        # Current user added or changed an omniauth strategy
        @user = current_user.omniauth! auth

        flash[:notice] = flash_t :connected
      end

      # Redirect to profile edit page -- they added a strategy from there.
      redirect_to ediofy_user_setting_path
      # redirect_to edit_user_registration_path
    else
      # New user signing in/up via omniauth
      @user = User.find_or_create_for_omniauth auth
      @user.confirm
      sign_in @user

      flash[:notice] = flash_t :signed_in
      redirect_to after_sign_in_path_for @user
    end
  end

  def flash_t key
    t(key, scope: "ediofy.users.omniauth_callbacks.flash",
      provider: t(auth.provider, scope: "ediofy.users.omniauth_callbacks.providers"))
  end

  def signed_in_root_path resource_or_scope
    ediofy_root_path
  end

  def after_omniauth_failure_path_for scope
    if user_signed_in?
      edit_user_registration_path
    else
      new_user_session_path
    end
  end
end
