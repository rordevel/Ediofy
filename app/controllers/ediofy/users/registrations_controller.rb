class Ediofy::Users::RegistrationsController < Devise::RegistrationsController
  layout 'session_signup', :only => [:new, :create]
  before_action :configure_permitted_parameters
  # skip_before_action :ensure_ediofy_terms_accepted
  skip_before_action :ensure_on_boarding_process_completed
  self.scoped_views = false

  # Switch update_with_password to update_attributes, copy password guarding
  def update
    # if params[:user][:interests_selected].present? && params[:user][:interests_selected] && !params[:user][:interest_list].present?
    #   redirect_to ediofy_interests_path, flash: { alert: "Please select atleast one interest" }
    #   return
    # end
    
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)

    # if  ( current_user.avatar.blank?  ||  current_user.avatar.nil? ) 
    #   if  (( params[:user][:full_name].present? && ((params[:user][:avatar].nil? || params[:user][:avatar].blank?))  ))
    #     redirect_to edit_user_registration_path, flash: { alert: "Please set your profile image" }
    #     return
    #   end
    # end
    
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params| 
      attributes = [:email, :password, :password_confirmation, :ediofy_terms_accepted]
      user_params.permit(attributes)
    end
    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      attributes = [:email, :full_name,:specialty_id, :title, :location, :qualifications, :about, :avatar_choice, :profile_completed, :interests_selected, :follows_selected, :avatar, :remove_avatar, interest_list:[]]
      user_params.permit(attributes)
    end
  end
  def update_resource(resource, params)
    if params["password"].blank? && params["password_confirmation"]
      resource.update_without_password(params)
    else
      resource.update(params)
    end
  end

  def after_sign_up_path_for resource
    ediofy_root_path
  end

  def after_update_path_for resource
    ediofy_user_path(resource)
  end

  def after_inactive_sign_up_path_for resource
    email_verification_path(email: resource.email)
  end
end