class Ediofy::Users::SettingsController < EdiofyController
  before_action :prepare_user, only: [:show]

  def update_password
    if update_resource(current_user, change_password_params)
      @password_updated = true
      bypass_sign_in current_user, scope: :user
    end
    render :change_password
  end

  def update_profile
    current_user.update_attributes(update_profile_settings_params)
    if !current_user.errors.messages.empty?
      prepare_user
      render :show
    else
      redirect_to ediofy_user_setting_path
    end
  end

  def deactivate
    current_user.update_columns(is_active: false)
    redirect_to ediofy_user_setting_path
  end

  def activate
    current_user.update_columns(is_active: true)
    redirect_to ediofy_user_setting_path
  end

  def update
    current_user.setting.update_attributes(setting_param)
    respond_with current_user.setting, location: ediofy_user_setting_path
  end

  def change_ghost_mod
    if current_user
      current_user.update_attributes(ghost_mode: params[:checked])
    end
  end

  protected

  def update_resource(resource, params)
    resource.update_with_password(params)
  end

  def change_password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
  def setting_param
    params.require(:setting).permit(:user_id, :tag_choice, :privacy_public, :privacy_friends,
                                    :question_reset_date, :question_reset, :send_updates,
                                    :ghost_mode, :private, tag_ids: []
                                    )
  end

  def update_profile_settings_params
    params.require(:user).permit(:email, :ghost_mode, :private, :cpd_from, :cpd_to)
  end

  def prepare_user
    @user = current_user
  end

end
