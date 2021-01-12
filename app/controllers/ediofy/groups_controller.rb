
class Ediofy::GroupsController < EdiofyController
  include FilterResult
  before_action :set_group, only: %i[show edit update destroy join leave roles report
                                    accept_invite remove_content cancel_invite]
  before_action :check_authorization, only: %i[edit update]
  
  def index
    # search_and_filter
    @mygroups = current_user.groups
    @mygroups = sort_group(@mygroups) if params[:my_groups]

    if params[:type] == 'public'
      @groups = Group.where(ispublic: true)
    elsif params[:type] == 'private'
      @groups = Group.where(ispublic: false)
    else
      @groups = Group.all
    end

    @groups.includes(:members, users: [:group_memberships])

    @groups = sort_group(@groups)
    # remove user groups
    @groups = @groups.reject { |g| @mygroups.map(&:id).include? g.id }

    # Pagination
    page = params[:page] || 1
    limit = 14
    @groups = Kaminari.paginate_array(@groups.to_a, total_count: @groups.count).page(page).per(limit)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @group = current_user.groups.new
    @group.build_image unless @group.image
    @path = "#"
  end
  
  def edit
    @group.build_image unless @group.image
  end
  
  def show
    
    #save_view_history(@group)
    @image = @group.image

    if params[:query].present? && params[:query].length > 0
      if params[:sort_by].present?
        @group_content =  @group.query_content(params[:query]).sort_by! {|c| c.created_at}.reverse!
        @group_top_content = sort_content @group_content, params[:type]
      else 
        @group_content =  @group.query_content(params[:query]).sort_by! {|c| c.created_at}.reverse!
        @group_top_content =  @group.top_content_in_search(params[:query])
     end
    
    else
      @group_content =  @group_content.nil? ? @group.content.sort_by! {|c| c.created_at}.reverse! : @group_content 
      @group_top_content = sort_content @group_content, params[:type]
    end

    if params[:archived] == "true"
       @group_playlists = @group.playlists.order('created_at DESC')
    else
      @group_playlists = @group.playlists.where("archived IS NULL OR archived = false").order('created_at DESC')
    end

    if params[:type].present?
      @group_content = select_group_content_by_type @group_content, params[:type]
      @group_top_content = select_group_content_by_type @group_top_content, params[:type]
    end

    if params[:sort_by].present?
      @group_content = sort_content @group_content, params[:type]
      @group_top_content = sort_content @group_top_content, params[:type]
    end

    
  end
  
  def update
    if @group.update_attributes(group_params)
      redirect_to ediofy_group_path(@group), notice: "Group has started successfull!"
    else
      render :new
    end
  end
  
  def create
    mod_group_params = group_params
    invited_users = mod_group_params.delete(:user_ids).reject { |e| e.empty? }
    @group = current_user.groups.new(mod_group_params)

    if @group.save
      @group.owners << current_user
      @group.users.delete current_user
      User.find(invited_users).each { |user| create_invite @group, user }
      redirect_to ediofy_group_path(@group), notice: "Group has started successfull!"
    else
      render :new
    end
  end

  def destroy
    if @group.destroy
      redirect_to ediofy_groups_path, notice: 'Group has been deleted successfull!'
    else
      redirect_to edit_ediofy_group_path(@group), alert: @group.errors.full_messages.first
    end
  end

  def join
    if @group.ispublic?
      @group.users << current_user
      flash[:notice] = 'You have successfully joined to the group!'
    else
      invite = @group.group_invites.create(user: current_user, invite_type: :request)
      notify_admins invite.id
      flash[:notice] = 'You have successfully request invite to join group!'
    end
    redirect_to ediofy_group_path(@group)
  end

  def leave
    redirect_to ediofy_group_path(@group) if @group.members.delete current_user
  end

  def report
    NotificationMailer.content_reported([ENV['ADMIN_EMAIL']], current_user, @group).deliver_now
    redirect_to ediofy_group_path(@group)
  end

  def roles
    unless params[:act] == 'invite_member' or @group.owners.include? current_user
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_group_path(@group))
    end

    @user = User.find(params[:user_id])
    case params[:act]
    when 'transfer_ownership'
      @group.owners.delete current_user
      @group.owners << @user
      @group.admins.delete @user
      @group.admins << current_user
    when 'add_to_admins'
      @group.admins << @user
      @group.users.delete @user
    when 'delete_from_admins'
      @group.admins.delete @user
      @group.users << @user
    when 'remove_member'
      @group.members.delete @user
    when 'invite_member'
      create_invite @group, @user
    when 'add_member'
      @group.users << @user
      @user.notifications.create! title: "#{current_user.full_name} has added you to the group #{@group.title}"
    end
    # TODO: i guess we need notifications after all those actions right?
    # user.notifications.create! title: "You have been #{params[:act]} to\from #{@group.title}"
    @group.reload
    respond_to do |format|
      format.html { redirect_to ediofy_group_path(@group) }
      format.js
    end
  end

  def accept_invite
    invite = @group.group_invites&.find(params[:invite_id])
    act = params[:act] == 'accept' ? 'accepted' : 'declined'
    if act == 'accepted'
      invite&.accept!
      flash[:notice] = 'Invite accepted successfully'
    else
      invite&.decline!
      flash[:notice] = 'Invite declined successfully'
    end

    Notification.find(params[:notification_id])&.update(title: "has invited you to join the group #{invite.group.title} for #{invite.user.full_name} #{act}.")
    redirect_back fallback_location: ediofy_root_url
  end

  def cancel_invite
    user = User.find(params[:user_id])
    return unless user && @group.invited?(user)
    @group.user_invite(user).delete
    user.notifications&.find_by(sender_id: current_user, notification_type: "invite_to_group_#{@group.id}")&.delete
    respond_to do |format|
      format.html { redirect_to ediofy_group_path(@group) }
      format.js
    end
  end

  def remove_content

    content = Object.const_get(params[:klass]).find(params[:content_id])

    able_to_destroy = content.groups.size == 1 && content.groups.first == @group &&
                      @group.ispublic == false &&  content.group_exclusive

    klass = params[:klass].pluralize.downcase
    @group.send(klass).delete content

    content.destroy if able_to_destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: ediofy_root_url }
    end
  end

  private

  def group_params
    params.require(:group).permit(:title, :description, :query, :group_url, :image, :ispublic, user_ids: [], admin_ids: [], owner_ids: [])
  end

  def set_group
    @parent = @group = Group.includes(:members).find(params[:id])
  end

  def create_invite(group, user)
    invite = group.group_invites.create(user: user, invite_type: :invite)
    notifi = user.notifications.create! notification_type: "invite_to_group_#{group.id}"
    notifi.update title: I18n.t("notification.group.invite.title_html",
                                group_name:  group.title,
                                accept_path: accept_invite_ediofy_group_path(id: group.id, invite_id: invite.id, act: 'accept', notification_id: notifi.id),
                                decline_path: cancel_invite_ediofy_group_path(id: group.id, user_id: user.id, act: 'decline', notification_id: notifi.id),
    ), sender: current_user

    NotificationMailer.group_invite(@group, current_user, user, invite, notifi).deliver_later
  end

  def notify_admins(invite_id = nil)
    users = @group.admins + @group.owners
    users.each do |u|
      notifi = u.notifications.create!
      notifi.update title: I18n.t("notification.group.request.title_html",
                                  group_name:  @group.title,
                                  accept_path: accept_invite_ediofy_group_path(id: @group.id, invite_id: invite_id, act: 'accept', notification_id: notifi.id),
                                  decline_path: cancel_invite_ediofy_group_path(id: @group.id, user_id: current_user.id, act: 'decline', notification_id: notifi.id),
                                  ), sender: current_user

      NotificationMailer.group_join_request(@group, current_user, u, invite_id, notifi).deliver_later
    end
  end

  def sort_group(groups)
    if params[:sort_by] == 'most_popular'
      groups.sort { |z, x| z.members.size <=> x.members.size }.reverse
    elsif params[:sort_by] == 'latest'
      groups.order('created_at DESC')
    else
      groups
    end
  end




  def select_group_content_by_type(content_array, type)
    content_array.select do |content|
      content.respond_to?(:content_type) ?
          content.content_type == type :
          content.class.to_s.downcase.pluralize == type.pluralize
    end
  end

  def sort_content(content, sort_by)
    if params[:sort_by] == 'most_popular'
      content.sort do |z, x|
        z&.comments_count + z&.cached_votes_up + z&.view_count <=> x&.comments_count + x&.cached_votes_up + x&.view_count
      end.reverse
    elsif sort_by == 'latest'
      content.order('created_at DESC')
    else
      content
    end
  end

  def check_authorization
    unless @group.owners.include? current_user
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_group_path(@group))
    end
  end
end
