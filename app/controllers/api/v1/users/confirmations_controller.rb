module Api
  module V1
    module Users
      class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
        protect_from_forgery with: :null_session
        def create
          unless params[:email]
            return render json: {
              status: FAIL_STATUS,
              full_messages: ['You must provide an email address.']
            }, status: 400
          end

          # unless params[:redirect_url]
          #   return render json: {
          #     status: FAIL_STATUS,
          #     full_messages: ['Missing redirect url.']
          #   }, status: 400
          # end
          # No need to redirect url its has been set in email template
          if resource_class.case_insensitive_keys.include?(:email)
            email = params[:email].downcase
          else
            email = params[:email]
          end

          q = "uid = ? AND provider='email'"

          # fix for mysql default case insensitivity
          if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
            q = "BINARY uid = ? AND provider='email'"
          end

          @resource = resource_class.where(q, email).first

          full_messages = nil

          if @resource
            @resource.send_confirmation_instructions({
              redirect_url: params[:confirm_success_url],
              client_config: params[:config_name]
            })
          else
            full_messages = ["Unable to find user with email '#{email}'."]
          end

          if full_messages
            render json: {
              status: FAIL_STATUS,
              full_messages: full_messages
            }, status: 400
          else
            render json: {
              status: SUCCESS_STATUS,
              message:   "Confirmation instruction has been sent to #{@resource.email}"
            }
          end
        end
      end
    end
  end
end
