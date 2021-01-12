class Ediofy::ConversationsController < EdiofyController
  include NewFilter
  include PlaylistsHelper

  before_action :set_conversation, only: %i[show edit update add_to_playlist destroy share_to_group]
  before_action :check_authorization, only: %i[edit update destroy]

  def index
    @conversations, @total, @has_more = conversations_search

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @conversation = current_user.conversations.new
    @cpd_point = ActivityKeyPointValue['conversation.new']&.cpd_time
  end

  def edit
    render :new
  end

  def show
    current_user.activity! 'conversation.read', conversation: @conversation, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'conversation.read')&.cpd_time
    save_view_history(@conversation)
    @images = @conversation.images
    find_playlist_from_params
    find_playlist_links(@conversation)
  end

  def update
    if @conversation.update_attributes(conversation_params.except(:posted_as_group))
      if @conversation.group_exclusive?
        @conversation.groups << Group.find(params[:group_id]) unless @conversation.groups.where(id: params[:group_id]).exists?
      end

      redirect_to ediofy_conversation_path(@conversation), notice: "Conversation has started successfull!"
    else
      render :new
    end
  end

  def create
    @conversation = current_user.conversations.new(conversation_params)
    if @conversation.save
      if params[:group_id]
        Group.find(params[:group_id]).conversations << @conversation
        @conversation.update(group_exclusive: true)
        @conversation.update(posted_as_group: params[:group_id]) if params[:conversation][:posted_as_group] == "true"
      end
      path = params[:group_id].present? ? ediofy_group_conversation_path(@conversation,  :group_id => params[:group_id]) : ediofy_conversation_path(@conversation)
      redirect_to path, notice: "Conversation has started successfull!"
    else
      render :new
    end
  end

  def destroy
    if @conversation.destroy
      redirect_to ediofy_conversations_path, notice: "Conversation has been deleted successfull!"
    else
      redirect_to edit_ediofy_conversation_path(@conversation), alert: @conversation.errors.full_messages.first
    end
  end

  def share_to_group
    Group.find(params[:group_id]).conversations << @conversation
    redirect_to ediofy_group_conversation_path(@conversation,  :group_id => params[:group_id]), notice: 'Conversation has been shared successfull!'
  end

  private

  def conversation_params
    params.require(:conversation).permit(:title, :description, :subject, :private, :all_comments, :tag_list, :group_id, :group_exclusive, :posted_as_group,
                                         images_attributes: [:file, :s3_file_name, :s3_file_url, :position, :id, :_destroy])
  end

  def set_conversation
    @parent = @conversation = Conversation.includes(:images, :tags).find(params[:id])
    @show_all_comments = params["show_all"] == "true"
  end

  def check_authorization
    if current_user != @conversation.user
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_conversation_path(@conversation))
    end
  end

  private

    def conversations_search
      options = {}
      options[:sort_by] = params[:sort_by] || 'latest'
      options[:content_type] = 'conversations'
      options[:query] = user_tags

      search('content', options)
    end
end
