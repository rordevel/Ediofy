# TODO not using in BETA
class Ediofy::Users::NotificationsController < Ediofy::UsersController

  before_action :prepare_user
  before_action :prepare_notification, only: [ :show, :destroy, :mark_as_read ]

  respond_to :json, :html

  def index
    @user.notifications.unread.each { |n| n.mark_as_read }
    @notifications = @user.notifications.order(created_at: :desc).page params[:page]

    respond_with @notifications
  end
  # def mentions
  #   usernames = User.where("id != ? AND username LIKE ?", current_user.id, "%#{params['q']}%").collect{|u| {username: u.username, name: u.full_name, image: u.avatar.x_small.url}}
  #   render json: usernames
  # end
  def mentions
    usernames = User.where("id != ? AND username LIKE ?", current_user.id, "%#{params['q']}%").collect{|u| {username: u.username, name: u.full_name, image: u.avatar.x_small.url}}
    render json: usernames
  end
  def show
    @notification.mark_as_read

    respond_with @notificaiton
  end

  def destroy
    @notification = @user.notifications.find(params[:id])
    @notification.destroy

    respond_with @notification, location: ediofy_user_notifications_url
  end

  def settings
    if request.get?
      if current_user.notification_setting.blank?
        @notification_setting = current_user.create_notification_setting
      else
        @notification_setting = current_user.notification_setting
      end
    else
      current_user.notification_setting.update(notification_setting_params)
      @notification_setting = current_user.notification_setting
      redirect_to settings_ediofy_user_notifications_path
    end
  end

  def mark_as_read
    @notification.mark_as_read

    respond_to do |format|
      format.html { redirect_to ediofy_user_notifications_url, notice: "Successfully marked notification read" }
      format.json { render json: @notification.as_json }
    end
  end

  def mark_all_read
    @user.notifications.unread.each { |n| n.mark_as_read }
    @notifications = @user.notifications.unread

    respond_to do |format|
      format.html { redirect_to ediofy_user_notifications_url, notice: "Successfully marked all notifications read" }
      format.json { render json: @notifications.as_json }
    end
  end


  protected

  def prepare_user
    @user = current_user
  end

  def prepare_notification
    @notification = @user.notifications.find(params[:id])
  end

  def notification_setting_params
    puts params.inspect
    params.require(:notification_setting).permit(:notify_follows, :notify_comments, :notify_likes, :notify_tags, :notify_followed_contributor_post, :email_follows, :email_comments, :email_likes, :email_tags, :notify_group_members_post, :notify_group_members_playlist_post)
  end

end