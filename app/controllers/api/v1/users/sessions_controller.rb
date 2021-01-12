module Api
  module V1
    module Users
      class SessionsController < DeviseTokenAuth::SessionsController
        protect_from_forgery with: :null_session
        resource_description{ resource_id "sessions" }

        api :POST, "/auth/sign_in", "sign in"
        param :email, String, required: true
        param :password, String, required: true
        def create          
          super
        end

        api :DELETE, "/auth/sign_out", "sign out"
        def destroy
          # remove auth instance variables so that after_action does not run
          user = remove_instance_variable(:@resource) if @resource
          client_id = remove_instance_variable(:@client_id) if @client_id
          remove_instance_variable(:@token) if @token

          if user and client_id and user.tokens[client_id]
            user.tokens.delete(client_id)
            user.save!

            yield user if block_given?
            user.update_attributes(device_token: params[:device_token], device_type: params[:device_type]) #reset device token and type
            render_destroy_success
          else
            render_destroy_error
          end
        end
        protected
        def render_create_success
          @resource.update_attributes(device_token: params[:device_token], device_type: params[:device_type])
          render json: {
            status: SUCCESS_STATUS,
            data: resource_data(resource_json: @resource.token_validation_response)
          }
        end
        def render_new_error
          render json: {
            status: FAIL_STATUS,
            full_messages: [ I18n.t("devise_token_auth.sessions.not_supported")]
          }, status: 405
        end

        def render_create_error_not_confirmed
          render json: {
            status: FAIL_STATUS,
            full_messages: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ]
          }, status: 401
        end

        def render_create_error_bad_credentials
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.sessions.bad_credentials")]
          }, status: 401
        end

        def render_destroy_success
          render json: {
            status: SUCCESS_STATUS
          }, status: 200
        end

        def render_destroy_error
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.sessions.user_not_found")]
          }, status: 404
        end
        private

        def render_error_banned_user
          render json: {
              status: FAIL_STATUS,
              full_messages: [I18n.t("devise_token_auth.sessions.disabled_account")]
          }, status: :forbidden
        end
      end
    end
  end
end
