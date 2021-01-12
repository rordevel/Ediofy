class Ediofy::LinksController < EdiofyController
  include PlaylistsHelper

  before_action :set_link, only: %i[show edit update destroy share_to_group add_to_playlist]
  before_action :check_authorization, only: %i[edit update destroy]

  def new
    @link = current_user.links.new
    @cpd_point = ActivityKeyPointValue['link.share']&.cpd_time
  end

  def create
    @link = current_user.links.build(link_params)
    if @link.save
      if params[:group_id]
        Group.find(params[:group_id]).links << @link
        @link.update(group_exclusive: true)
        @link.update(posted_as_group: params[:group_id]) if params[:link][:posted_as_group] == "true"
      end
      path = params[:group_id].present? ? ediofy_group_link_path(@link,  :group_id => params[:group_id]) : ediofy_link_path(@link)
      redirect_to path, notice: "Link was created successfull!"
    else
      render :new
    end
  end

  def edit
    render action: 'new'
  end

  def update
    if @link.update_attributes(link_params.except(:posted_as_group))
      if @link.group_exclusive?
        @link.groups << Group.find(params[:group_id]) unless @link.groups.where(id: params[:group_id]).exists?
      end

        @link.update(posted_as_group: @parent.posted_as_group) if link_params[:posted_as_group] == "true"
        redirect_to ediofy_link_path(@link)
    else
      render action: 'new'
    end
  end

  def show
    save_view_history(@link)
    find_playlist_from_params
    find_playlist_links(@link)
  end

  def parse
    begin
      page = MetaInspector.new params[:data][:url]
      page_info = {description: page.best_description.blank? ? "" : page.best_description[0,250], host: page.root_url, image: page.images.best}
      render json: {status: "success",page_info: page_info}
    rescue => e
      render json: {status: "fail", error_message: e.message, message: "System could not connect to '#{params[:data][:url]}'."}
    end
  end

  def destroy
    if @link.destroy
      redirect_to user_root_path, notice: "Link has been deleted successfull!"
    else
      redirect_to edit_ediofy_link_path(@link), alert: @link.errors.full_messages.first
    end
  end

  def update_cpd
    @link = Link.includes(:tags).find(params[:link_id])
    current_user.activity! 'link.view', link: @link, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'link.view')&.cpd_time
    render json: { status: :ok }
  end

  def share_to_group
    Group.find(params[:group_id]).links << @link
    redirect_to ediofy_group_link_path(@link, params[:group_id]), notice: 'Link has been shared successfull!'
  end

  private

  def link_params
    params.require(:link).permit(:title,:url, :description, :page_image, :private, :page_description,
                                 :tag_list, :posted_as_group, :all_comments, :group_id, :group_exclusive, :posted_as_group,
                                 images_attributes: [:file, :s3_file_name, :s3_file_url, :position, :id, :_destroy])
  end

  def set_link
    @parent = @link = Link.includes(:tags).find(params[:id])
    @show_all_comments = params["show_all"] == "true"
  end

  def check_authorization
     if @link.user.id != current_user.id
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_link_path(@link))
    end
  end
end
