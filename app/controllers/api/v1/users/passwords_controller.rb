module Api
  module V1
    module Users
      class PasswordsController < DeviseTokenAuth::PasswordsController
        protect_from_forgery with: :null_session
        resource_description{ resource_id "passwords" }
        
        api :POST, "/auth/password", "Reset Password"
        param :email, String, required: true
        def create
          unless resource_params[:email]
            return render_create_error_missing_email
          end

          # give redirect value from params priority
          @redirect_url = ediofy_root_url#params[:redirect_url] #remove redirect url param

          # fall back to default value if provided
          @redirect_url ||= DeviseTokenAuth.default_password_reset_url

          unless @redirect_url
            return render_create_error_missing_redirect_url
          end

          # if whitelist is set, validate redirect_url against whitelist
          if DeviseTokenAuth.redirect_whitelist
            unless DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
              return render_create_error_not_allowed_redirect_url
            end
          end

          # honor devise configuration for case_insensitive_keys
          if resource_class.case_insensitive_keys.include?(:email)
            @email = resource_params[:email].downcase
          else
            @email = resource_params[:email]
          end

          q = "uid = ? AND provider='email'"

          # fix for mysql default case insensitivity
          if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
            q = "BINARY uid = ? AND provider='email'"
          end

          @resource = resource_class.where(q, @email).first

          @errors = nil
          @error_status = 400

          if @resource
            yield @resource if block_given?
            @resource.send_reset_password_instructions({
              email: @email,
              provider: 'email',
              redirect_url: @redirect_url,
              client_config: params[:config_name]
            })

            if @resource.errors.empty?
              return render_create_success
            else
              @errors = @resource.errors
            end
          else
            @errors = [I18n.t("devise_token_auth.passwords.user_not_found", email: @email)]
            @error_status = 404
          end

          if @errors
            return render_create_error
          end
        end
        protected
        def resource_update_method
          if DeviseTokenAuth.check_current_password_before_update == false or @resource.allow_password_change == true
            "update_attributes"
          else
            "update_with_password"
          end
        end

        def render_create_error_missing_redirect_url
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.passwords.missing_redirect_url")]
          }, status: 401
        end

        def render_create_error_not_allowed_redirect_url
          render json: {
            status: 'error',
            data:   resource_data,
            full_messages: [I18n.t("devise_token_auth.passwords.not_allowed_redirect_url", redirect_url: @redirect_url)]
          }, status: 422
        end

        def render_edit_error
          raise ActionController::RoutingError.new('Not Found')
        end

        def render_update_error_unauthorized
          render json: {
            status: FAIL_STATUS,
            full_messages: ['Unauthorized']
          }, status: 401
        end

        def render_update_error_password_not_required
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.passwords.password_not_required", provider: @resource.provider.humanize)]
          }, status: 422
        end

        def render_update_error_missing_password
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.passwords.missing_passwords")]
          }, status: 422
        end

        def render_update_success
          render json: {
            status: SUCCESS_STATUS,
            data: resource_data,
            message: I18n.t("devise_token_auth.passwords.successfully_updated")
          }
        end

        def render_update_error
          return render json: {
            status: FAIL_STATUS,
            full_messages: resource_errors
          }, status: 422
        end

        def render_create_error_missing_email
          render json: {
            status: FAIL_STATUS,
            full_messages: [I18n.t("devise_token_auth.passwords.missing_email")]
          }, status: 401
        end

        def render_create_success
          render json: {
            status: SUCCESS_STATUS,
            message: I18n.t("devise_token_auth.passwords.sended", email: @email)
          }
        end

        def render_create_error
          render json: {
            status: FAIL_STATUS,
            full_messages: @errors,
          }, status: @error_status
        end
      end
    end
  end
end
