class EdiofyController < ApplicationController
=begin
  TODO not required in Beta
  helper 'ediofy/share'
  helper 'ediofy/oembed_provider'
=end
  before_action :authenticate_user!
  before_action :store_location
  before_action :check_user_profile!

  # Ensure we store which URL the user tried to access so when they sign in it returns them to that page
  def store_location
    session[:user_return_to] = request.url if request.get? and controller_name != "sessions" and controller_name != "registrations" and controller_name != "omniauth_callbacks"
  end

  def check_user_profile!
    if user_signed_in? && current_user.email.end_with?('.auth') && current_user.ediofy_terms_accepted
      redirect_to edit_user_registration_path, alert: 'Please add a valid e-mail address to your account'
    end
  end
  def check_user_onboarding_state
    if current_user.interests.length == 0 && current_user.follows.length == 0 && FollowRequest.where(:follower_id => current_user.id ).limit(1).blank?
      return false
    end
    true
  end

  def check_and_reset_user_onboarding_state
    unless current_user.interests.length > 0
      current_user.interests_selected = false
    end
    if current_user.follows.length == 0 && FollowRequest.where(:follower_id => current_user.id ).limit(1).blank?
      current_user.follows_selected = false
    end
    current_user.save!
  end

  def save_view_history(viewable)
    if (viewable.class.name == "User" && viewable != current_user) || (viewable.class.name != "User" && current_user != viewable.user)
      viewable.update_column(:view_count, viewable.view_count.to_i.succ)
    end
    unless viewable == current_user
      history = current_user.viewed_histories.find_by(viewable_id: viewable.id, viewable_type: viewable.class.to_s)
      unless history.blank?
        history.update_column(:updated_at, Time.now)
      else
        current_user.viewed_histories.create(viewable_id: viewable.id, viewable_type: viewable.class.to_s)
      end
    end
  end
  def redirect_back_or_default(options, default)
    options ||= {}
    default ||= user_root_path
    options[:fallback_location] = default
    redirect_back options
  end
end
