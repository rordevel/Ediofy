class Ediofy::CommentsController < EdiofyController
  before_action :set_commentable
  before_action :set_comment, only: [:reply, :edit]


  def index
    page = params[:page] || 1
    per = 10

    if request.referrer.include?('groups/') && params["all_comments"] != "true" #show only group comments
      @group = Group.find(URI(request.referer).path.split("/")[2])
      @comments = @commentable.blank? ? [] : @commentable.comments.where(parent_id: nil, group_id: @group.id).order(id: :asc).page(page).per(per)
    elsif request.referrer.include?('groups/') && params["all_comments"] == "true" #public comments
      @comments = @commentable.blank? ? [] : @commentable.comments.where(parent_id: nil, group_id: nil).order(id: :asc).page(page).per(per)
    else 
      @comments = @commentable.blank? ? [] : @commentable.comments.where(parent_id: nil,  group_id: nil ).order(id: :asc).page(page).per(per) 
    end
  end

  def create

    if params[:comment][:edit_id].present?
      @c = Comment.find(params[:comment][:edit_id])
      @c.comment = params[:comment]["comment"]
      @c.save
    else 
      @comment = @commentable.comments.by(current_user).build comment_params
      @comment.user_agent = request.env['HTTP_USER_AGENT']
      @comment.ip_address = request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR']
      # If we are inside a group, associate comment to group
      if request.referrer.include?('groups/')
        @group = Group.find(URI(request.referer).path.split("/")[2])
        @comment.group = @group
      end
    @comment.save
    end
  end
  
  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.destroy
    redirect_back fallback_location: ediofy_root_url
  end


  private

    def comment_params
      params.require(:comment).permit(:comment, :private, :parent_id, :replied_to, references_attributes: [:id, :title, :url, :_destroy])
    end



    def set_commentable
      resource = request.path.split('/')[1].singularize
      klass = resource.classify.constantize
      id = params["#{resource}_id"]
      @commentable = klass.find(id)
    end

    def set_comment
      @comment = @commentable.comments.find(params[:comment_id])
    end
end
