module Api
  module V1
    module Users
      class SettingsController < ApiController
        before_action :authenticate_user!
        before_action :set_user

        resource_description{ resource_id "settings" }

        api :GET, "users/settings", "Settings"
        def show
        end

        api :PUT, "users/settings", "Update settings"
        param :setting, Hash, "Setting" do
          param :privacy_public, String, desc: "1 for Open, 2 for Medium, 3 for Stealth"
          param :privacy_friends, String, desc: "1 for Open, 2 for Medium, 3 for Stealth"
          param :question_reset_date, String
          param :question_reset, String, "Monthly, When Exhausted"
          param :send_updates, String, "TRUE, FALSE"
          param :tag_ids, Array, of: "Ids", desc: "Array of tag ids"
        end
        def update
          current_user.setting.update_attributes(setting_param)
          render :show
        end

        protected

        def setting_param
          params.require(:setting).permit(:user_id, :privacy_public, :privacy_friends, :question_reset_date, :question_reset, :send_updates, tag_ids: [])
        end

      end
    end
  end
end