# TODO currently api's are not required in BETA
module Api
  module V1
    class ApiController < ActionController::Base
      include DeviseTokenAuth::Concerns::SetUserByToken
      protect_from_forgery with: :null_session
      RecoverableExceptions = [
          ActiveRecord::RecordNotUnique,
          ActiveRecord::RecordInvalid,
          ActiveRecord::RecordNotSaved
      ]

      rescue_from Exception do |e|
        error(E_API, "An internal API error occured. Please try again.\n #{e.message}")
      end

      def error(code = E_INTERNAL, message = 'API Error')
        render json: {
          status: STATUS_ERROR,
          error_no: code,
          message: message
        }, :status => HTTP_CRASH
      end

      def render_resource_failure(resource, resource_name)
        render :json => {
          status: FAIL_STATUS,
          resource_name.to_sym => resource,
          full_messages: resource.errors.full_messages
        }, status: HTTP_FAIL
      end

      

      def validate_json
        begin
          JSON.parse(request.raw_post).deep_symbolize_keys
        rescue JSON::ParserError
          error E_INVALID_JSON, 'Invalid JSON received'
          return
        end
      end

      # @param object - a Hash or an ActiveRecord instance
      def success(object = {})
        object = JSON.parse(object.to_json) unless object.instance_of?(Hash)
        render json: { status: STATUS_OK }.merge(object)
      end

      def check_user_eula_and_privacy
        #TODO incorporate caching
        latest_eula = Eula.find_by_is_latest(true)
        latest_privacy = Privacy.find_by_is_latest(true)
        if latest_eula.id != current_user.eula_id || latest_privacy.id != current_user.privacy_id
          render json: { deprecated_eula: latest_eula.id != current_user.eula_id,
                         deprecated_privacy: latest_privacy.id != current_user.privacy_id }, status: '419' and return
        end
      end
      private
      def prevent_admin!
        if user_signed_in? && current_user.administrator?
          render json:{status: FAIL_STATUS, full_message: ["You are not authorized to perform this action"]}, status: 401
        end
      end
      
      def set_user
        @user = current_user
      end

    end
  end
end
