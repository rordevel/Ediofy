class Ediofy::ReportsController < EdiofyController
  before_action :get_reportable
  before_action :build_report, except: [:report]
  def create
    @report.save
    # redirect_back fallback_location: ediofy_root_url, notice: "Thank you for reporting this content to Edify. One of our team members will take a look into this and get it resolved"
  end
  private
  def get_reportable
    if params[:conversation_id].present?
      @reportable = Conversation.find params[:conversation_id]
    elsif params[:question_id].present?
      @reportable = Question.find params[:question_id]
    elsif params[:media_id].present?
      @reportable = Media.find params[:media_id]
    elsif params[:comment_id].present?
      @reportable = Comment.find params[:comment_id]
    elsif params[:link_id].present?
      @reportable = Link.find params[:link_id]
    elsif params[:announcement_id].present?
      @reportable = Announcement.find params[:announcement_id]
    end
  end
  def reportable_report_params
    params.require(:report).permit(:media_id, :user_id, :reason, :comments)  
  end
  def build_report
    @report = @reportable.reports.by(current_user).build reportable_report_params
  end
end
