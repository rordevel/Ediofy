module Api
  module V1
    module Users
      class ProfilesController < ApiController
        before_action :authenticate_user!
        before_action :set_user

        resource_description{ resource_id "profiles" }

        api :GET, "users/profile", "profile"
        def show
          
        end

        api :PUT, "users/profile", "update profile"
        param :user, Hash, "User" do
          param :device_type, String
          param :device_token, String
          param :password, String, desc: 'Reset password'
          param :first_name, String
          param :last_name, String
          param :biography, String
          param :website, String
          param :hospital, String
          param :university_group_id, String
          param :avatar_choice, String, desc: 'e.g. current, upload, gravatar'
          param :avatar, String, desc: 'Attach file'
        end
        def update
          if @user.update_attributes(user_params)
            render action: :show
          else
            render_resource_failure(@user, "data")
          end
        end
        def confirm_password
          if current_user.valid_password?(params["password"])
            render json: {status: SUCCESS_STATUS, message: "Password matched"}
          else
            render :json => {
              status: FAIL_STATUS,
              full_messages: ["Invalid password"]
            }, status: 402
          end
        end
        private
        def user_params
          params.require(:user).permit(:device_type, :device_token, :password, :first_name, :last_name, :biography, :website, :hospital, :university_group_id, :avatar_choice, :avatar)
        end
        def set_user
          @user = current_user
        end
      end
    end
  end
end
