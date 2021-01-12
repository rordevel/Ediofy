class Ediofy::FollowsController < EdiofyController
  include FilterResult
  skip_before_action :ensure_on_boarding_process_completed
  
  

  def index
    search_and_filter_follow
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @user = User.find(params[:follow_id])
    current_user.unblock(@user)
    current_user.follow(@user)
  
    
  end

  def accept
    @user = User.find(params[:user_id])
    @user.unblock(current_user)
    @user.follow(current_user)

    FollowRequest.find(params[:followrequest_id])&.destroy

    #move this to a model callback
    Notification.find(params[:notification_id])&.destroy
    
    
    redirect_to user_root_path

  end

  def reject
    FollowRequest.find(params[:followrequest_id])&.destroy

    Notification.find(params[:notification_id])&.destroy  

    redirect_to user_root_path
  end


  def request_follow
    u = User.find(params[:user_id])

    followRequest = FollowRequest.new({follower_id: current_user.id, followee_id: u.id })
    followRequest.save

    n =  u.notifications.create!
    n.update  notification_type: "FollowRequest",
     sender: current_user,
      title: I18n.t("notification.follows.request.title_html",
      user_full_name: current_user.full_name,
      accept_path:  ediofy_follow_accept_invite_path(user_id:current_user.id, act: 'accept', followrequest_id: followRequest.id, notification_id: n.id),
      decline_path: ediofy_follow_cancel_invite_path(user_id: current_user.id,  act: 'decline', followrequest_id: followRequest.id, notificaiton_id: n.id)
      )

     if followRequest
         head :no_content
     else
      render nothing: true, status: "error"
     end
  end

  def destroy
    @user = User.find(params[:id])
    current_user.stop_following(@user)
  end

  def cancel
    @user = User.find(params[:user_id])
    f = FollowRequest.find_by(follower_id: current_user.id, followee_id:params[:user_id])
    f.destroy!

    head :no_content

  end



  private

  def follow_params
    params.require(:follow).permit(:user_id, :pending, :followrequest_id)
  end
end
