class Ediofy::MediaController < EdiofyController
  include PlaylistsHelper

  before_action :build_media, only: [:create]


  before_action :prepare_media, only: %i[show edit update destroy share_to_group add_to_playlist]

  before_action :load_media_collection, only: :remove_from_collection
  before_action :prepare_media_collection, only: :add_to_collection

  before_action :load_user_collection, only: :remove_from_user_collection
  before_action :prepare_user_collection, only: :add_to_user_collection
  before_action :check_authorization, only: [:edit, :update, :destroy]

  respond_to :html, :atom

  def new
    @media = current_user.media.build
    # @media.media_files.build
    @media.references.build
    @path = ediofy_media_index_path
    @cpd_point = ActivityKeyPointValue['media_files.new']&.cpd_time
  end

  def edit
    @path = ediofy_media_path @media
    @media.references.build if @media.references.empty?
    render :new
  end

  def update
    if @media.update_attributes(media_params.except(:posted_as_group))
      if @media.group_exclusive?
        @media.groups << Group.find(params[:group_id]) unless @media.groups.where(id: params[:group_id]).exists?
      end

      respond_with :ediofy, @media
    else
      @path = ediofy_media_path @media
      @media.references.build if @media.references.empty?
      render :new
    end
  end

  def destroy
    if @media.destroy
      redirect_to user_root_path, notice: "media has been deleted successfull!"
    else
      redirect_to edit_ediofy_media_path(@media), alert: @media.errors.full_messages.first
    end
  end

  def create
    unless @media.save
      @path = ediofy_media_index_path
      @media.references.build if @media.references.empty?
    end
    if params[:group_id]
      Group.find(params[:group_id]).media << @media
      @media.update(group_exclusive: true)
      @media.update(posted_as_group: params[:group_id]) if params[:media][:posted_as_group] == "true"
    end
    path = params[:group_id].present? ? ediofy_group_media_path(@media,  :group_id => params[:group_id]) : ediofy_media_path(@media)
    redirect_to path, notice: "Media created successfully"
  end

  def show
 
    if @media.content_type == 'image'
      current_user.activity! 'image.view', media: @media, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'image.view')&.cpd_time
    end
    save_view_history(@media)
    @mediable = params["mediable"]
    if @media.media_files
      @media_files = @media.media_files
    else
      raise ActiveRecord::RecordNotFound
    end
    find_playlist_from_params
    find_playlist_links(@media)

    respond_with :ediofy, @media
  end


  # TODO Following methods are not being used in BETA, need in next version for notification
  def popup
    if @media.media_collection
      @media_collection = @media.media_collection
    else
      raise ActiveRecord::RecordNotFound
    end
    render layout: 'ediofy_popup'
  end

  def add_to_collection
    unless @media_collection.media.include? @media
      @media_collection.media << @media
    end
    respond_with @media, location: [:ediofy, @media]
  end

  def remove_from_collection
    @media_collection.media.delete @media
    respond_with @media, location: [:ediofy, @media]
  end

  def add_to_user_collection
    @user_collection.media << @media
    respond_with @media, location: [:ediofy, @media]
  end

  def remove_from_user_collection
    @user_collection.media.delete @media
    respond_with @media, location: [:ediofy, @media]
  end

  def create_tag
    @media.tags_list = params[:tag]
    @media.save
    render json: { status: :ok }
  end

  def destroy_tag
    if current_user != @media.user
      render json: { status: :err, error: 'Unauthorized' }, status: 401
    else
      @media.tag_list.delete(params[:tag])
      @media.save
      render json: { status: :ok }
    end
  end
  # TODO END

  def share_to_group
    @media = Media.find(params[:id])
    Group.find(params[:group_id]).media << @media
    redirect_to ediofy_group_media_path(@conversation,  :group_id => params[:group_id]), notice: 'Media has been shared successfull!'
  end

  def update_cpd
    render json: { status: :ok } and return unless params[:media_type].in?(['video', 'audio', 'pdf'])
    render json: { status: :ok } and return unless params[:played_duration].present?
    render json: { status: :ok } and return unless params[:played_duration].to_f > 0

    media_file = MediaFile.find(params[:media_file_id])

    if params[:media_type].in?(['video', 'audio'])
      mins = (params[:played_duration].to_f / 60).ceil
      mins = mins > 6 ? 6 : mins
      played_mins = (ActivityKeyPointValue.find_by(activity_key: 'media.watch')&.cpd_time || 0) * mins

      activity = current_user.activities.where(key: 'media.watch').select { |a| a.relations.values.first == media_file }.first

      if activity
        activity.variables[:played_duration] = (params[:played_duration].to_f / 60).round(1)
        activity.save

        cpd_time = CpdTime.find_or_initialize_by(user_id: current_user.id, activity_id: activity.id)
        cpd_time.value = played_mins
        cpd_time.save
      else
        current_user.activity! 'media.watch', media: media_file, cpd_time: played_mins
      end
    elsif params[:media_type] == 'pdf' && params[:played_duration].to_i > 0
      played_mins = 60 * params[:played_duration].to_i

      activity = current_user.activities.where(key: 'pdf.view').select { |a| a.relations.values.first == media_file }.first

      if activity
        activity.variables[:played_duration] = played_mins
        activity.save

        cpd_time = CpdTime.find_or_initialize_by(user_id: current_user.id, activity_id: activity.id)
        cpd_time.value = played_mins
        cpd_time.save
      else
        current_user.activity! 'pdf.view', media: media_file, cpd_time: played_mins
      end
    end

    render json: { status: :ok }
  end

  protected

  def media_params
    params.require(:media).permit(:title, :description, :tag_list, :file, :file_cache, :private, :all_comments, :group_id, :group_exclusive, :posted_as_group,
                                  references_attributes: [:id, :title, :url, :_destroy],
                                  media_files_attributes:[:id, :s3_file_name, :s3_file_url, :file_path, :position, :file, :media_type, :_destroy])
  end

  def prepare_scope
    @scope = MediaFile.visible_to current_user
  end

  def prepare_media
    @parent = @media = Media.find params[:id]
    @show_all_comments = params["show_all"] == "true"
  end

  def prepare_media_collection
    if params[:media_collection_id] == 'new' && params[:media_collection_name].present?
      @media_collection = current_user.media_collection.build( title: params[:media_collection_name], description: '')
      @media_collection.save( validate: false)
    else
      load_media_collection
    end
  end

  def load_media_collection
    @media_collection = current_user.media_collection.find params[:media_collection_id]
  end

  def build_media
    @media = current_user.media.new media_params
  end

  def interpolation_options
    {media: @media.try(:to_s), media_collection: @media_collection.try(:to_s)}
  end

  def prepare_user_collection
    if params[:user_collection_id] == 'new' && params[:user_collection_name].present?
      @user_collection = current_user.user_collections.build( title: params[:user_collection_name], description: '')
      @user_collection.save( validate: false)
    else
      load_user_collection
    end
  end

  def load_user_collection
    @user_collection = current_user.user_collections.find params[:user_collection_id]
  end

  private

  def check_authorization
    if current_user != @media.user
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_media_path(@media))
    end
  end
end
