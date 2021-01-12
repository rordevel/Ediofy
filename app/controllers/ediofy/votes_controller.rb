class Ediofy::VotesController < EdiofyController
  before_action :get_votable
  def up
    vote = @votable.vote_up current_user
    klass = @votable.class.name
    links = [{title: klass == "Conversation" ? "" : @votable.title, href: [:ediofy, @votable] }]
    if Notification.find_by(notifiable: @votable, notification_type: "Like", sender_id: current_user.id, receiver_id: @votable.user.id).blank? && current_user != @votable.user
      if !@votable.user.notification_setting.blank? && @votable.user.notification_setting.notify_likes
        @votable.user.notifications.create! notifiable: @votable, title: I18n.t("notification.vote.up", sender: current_user, votable: klass), body: "", links: links, sender_id: current_user.id, notification_type: "Like"
      end
      if !@votable.user.notification_setting.blank? && @votable.user.notification_setting.email_likes
        NotificationMailer.like(current_user, @votable.user, @votable).deliver_later
      end
    end
    respond_to do |format|
      format.js { render :template => "ediofy/shared/toolbar/voting" }
      format.html {redirect_back fallback_location: ediofy_root_url}
    end
  end
  def no
    @votable.unvote voter: current_user
    notification = Notification.find_by(notifiable: @votable, notification_type: ["Like", "Dislike"], sender_id: current_user.id, receiver_id: @votable.user.id)
    notification.destroy unless notification.blank?
    respond_to do |format|
      format.js { render :template => "ediofy/shared/toolbar/voting" }
      format.html {redirect_back fallback_location: ediofy_root_url}
    end
  end
  def down
    @votable.vote_down current_user
    respond_to do |format|
      format.js { render :template => "ediofy/shared/toolbar/voting" }
      format.html {redirect_back fallback_location: ediofy_root_url}
    end
  end

  private

  def get_votable
    @votable = if params[:conversation_id].present?
                 Conversation.find params[:conversation_id]
               elsif params[:question_id].present?
                 Question.find params[:question_id]
               elsif params[:media_id].present?
                 Media.find params[:media_id]
               elsif params[:link_id].present?
                 Link.find params[:link_id]
               elsif params[:comment_id].present?
                 Comment.find params[:comment_id]
               elsif params[:announcement_id].present?
                 Announcement.find params[:announcement_id]
               end
  end
end
