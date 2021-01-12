class ApplicationController < ActionController::Base
  responders :flash
  respond_to :html

  protect_from_forgery with: :null_session
  before_action :ensure_on_boarding_process_completed
  # after_action :prepare_unobtrusive_flash
  protected

  def set_flash_responder resource, scope
    status = :alert if resource.try(:errors).present?
    status ||= :notice
    flash[status] = I18n.t(status, scope: scope).html_safe
  end

  # Devise paths for default member and admin home paths
  def user_root_path
    if ediofy?
      ediofy_root_path
    else
      ediofy_root_path
    end
  end

  def admin_root_path
    admin_dashboard_path
  end

  def set_session_options_domain
    request.session_options[:domain] = request.domain
  end

  def ediofy?
    request.subdomain == "ediofy" or is_a? EdiofyController
  end
  def authenticate_admin_user!
    session[:admin_return_to] = request.url if request.get? and controller_name != "sessions" and controller_name != "registrations" and controller_name != "omniauth_callbacks"
    super
  end
  def ensure_on_boarding_process_completed
    if user_signed_in?
      if (current_user.facebook? || current_user.twitter? || current_user.linkedin? || current_user.google?) && !current_user.ediofy_terms_accepted
        redirect_to ediofy_terms_path  
      elsif not current_user.profile_completed
        redirect_to edit_user_registration_path
      elsif not current_user.interests_selected
        redirect_to ediofy_interests_path  
      elsif not current_user.follows_selected
        redirect_to ediofy_follows_path
      end
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    ediofy_terms_url == super ? ediofy_root_url : super
  end

end
