class Ediofy::Users::EdiofyUserExamsController < Ediofy::UsersController
  before_action :prepare_tags

  def new
    @exam = current_user.ediofy_user_exams.build
    @exam.exam_mode = params[:exam_mode].to_i || 5
  end

  def create
    if params[:ediofy_user_exam][:exam_mode].to_i == 0
      @exam = current_user.ediofy_user_exams.unfinished.where( exam_mode: 0 ).first
      unless params[:ediofy_user_exam][:tag_ids].present?
        params[:ediofy_user_exam][:tag_ids] = current_user.setting.tag_ids
      end
    end


    @exam ||= current_user.ediofy_user_exams.create(exam_params)
    if @exam.valid?
      respond_with @exam, location: [ :ediofy, :user, @exam, @exam.exam_questions.first ]
    else
      respond_with @exam
    end
  end

  def complete
    flash[:notice] = t('ediofy.completed_exam')
    @exam = current_user.ediofy_user_exams.find(params[:id])
    @exam.update_attribute(:finished, true)

    if @exam.shuffle_mode?
      redirect_to ediofy_root_path
    elsif @exam.one_question_mode?
      redirect_to [ :ediofy, @exam.exam_questions.first.question ]
    else
      redirect_to [ :ediofy, :user, @exam, @exam.exam_questions.first ]
    end
  end



  protected

  def prepare_tags
    @tags = Tag.arrange( :order => :name )
  end

  private

  def exam_params
    params.require(:ediofy_user_exam).permit(:user_id, :exam_mode, :finished, tag_ids: []
    )
  end

end