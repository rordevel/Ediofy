module Api
  module V1
    class MediaController < ApiController
      before_action :authenticate_user!, only: [:report]
      before_action :prepare_scope, except: [:report]
      before_action :prepare_media, except: [:index, :new, :create, :report]
      before_action :set_media, only: [:report]

      resource_description { resource_id "Media" }

      api :GET, "/media", "Media list"
      param :query, String, desc: "Search Keywords"
      param :order_by, String, desc: "created_at, score"
      param :direction, String, desc: "desc, asc"
      def index
        @query = params[:query] || ""
        @order_by = params[:order_by]
        @limit = params[:limit]
        @direction = params[:direction]

        @scope = @scope.advanced_search query: @query,
                                        order_by: @order_by,
                                        limit: @limit,
                                        direction: @direction,
                                        user: current_user

        @media = @scope.includes(:tags, :user).page params[:page]
      end
      
      api :GET, "/media/:id", "Show Media"
      def show
      end

      api :GET, "/media/:id/view_more", "View more about media"
      def view_more
      end

      api :POST, "/media/:id/report", "Report a media"
      param :reason, String, required: true, desc: "Offensive, Inappropriate, Spam, Other"
      param :comments, String, desc: "Report comments"
      def report
        @media_report = @media.reports.by(current_user).create(media_report_params)
      end

      private

      def prepare_scope
        @scope = Media.visible_to current_user
      end
      def prepare_media
        @parent = @media = @scope.find params[:id]
      end
      def set_media
        @media = Media.find params[:id]
      end
      def media_report_params
        params.require(:report).permit(:reason, :comments) 
      end
    end
  end
end