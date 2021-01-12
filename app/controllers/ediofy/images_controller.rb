class Ediofy::ImagesController < EdiofyController
  before_action :prepare_parent, :set_image

  def destroy
    @image.destroy
  end
  private

  def prepare_parent
    if params[:question_id]
      @parent = Question.find(params[:question_id])
    elsif params[:conversation_id]
      @parent = Conversation.find(params[:conversation_id])
    end
  end
  def set_image
    @image = Image.find params[:id]
  end
end
