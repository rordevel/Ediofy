class Ediofy::Users::EdiofyUserExams::UserExamQuestionsController < Ediofy::UsersController
  include PlaylistsHelper

  skip_before_action :set_user, only: [:show]
  before_action :prepare_exam
  before_action :prepare_exam_question
  def show
    @parent = @question             = @exam_question.question
    @images = @question.images

    @answers              = @question.sorted_answers("#{current_user.email}#{@user_exam.id}")
    @selected_answer      = @exam_question.selected_answer
    @exam_questions       = @user_exam.paginated_questions params[:page] || @exam_question.page_number
    @question_explanation = current_user.question_explanations.build
    @tags               = Tag.arrange( :order => :name )
    @exam                 = current_user.ediofy_user_exams.build
    @exam.exam_mode       = params[:exam_mode].to_i || 5
    # If the question is already answers then display the review page,
    # otherwise display the show template.
    @comments = @question.comments.where(parent_id: nil).approved

    # TODO: Save history will be removed when question show wil be used to show question
    save_view_history(@question)

    # if @selected_answer.present? && @selected_answer.persisted?
    #   render :review
    # else
    #   render :show
    # end
    if @selected_answer.present? && @selected_answer.persisted?
      @review = true
    else
      @review = false
    end

    find_playlist_from_params
    find_playlist_links(@question)

    render :show
  end

  def update
    if params[:commit] == t(:skip, scope: [ :formtastic, :actions, :user_exam_question])
      redirect_to [ :ediofy, :user, @user_exam, @exam_question.lower_item || @user_exam.exam_questions.first ]
    else
      params[:user_exam_question][:selected_answer_attributes][:answer_order] = YAML::dump(@exam_question.question.sorted_answers(current_user.email).map(&:id))
      @exam_question.update_attributes(exam_question_params)

      next_question = @exam_question.next_unanswered

      if @user_exam.shuffle_mode? || @user_exam.one_question_mode?
        redirect_to [ :ediofy, :user, @user_exam, @exam_question ]
      elsif @exam_question.next_unanswered.present?
        redirect_to [ :ediofy, :user, @user_exam, @exam_question.next_unanswered ]
      else
        redirect_to [ :complete, :ediofy, :user, @user_exam ]
      end
    end
  end

  def answer
    params[:user_exam_question][:selected_answer_attributes][:answer_order] = YAML::dump(@exam_question.question.sorted_answers(current_user.email).map(&:id))
    @exam_question.update_attributes(exam_question_params)
    @question = @exam_question.question
    @selected_answer = @exam_question.selected_answer
  end

  def share_to_group
    Group.find(params[:group_id]).questions << @exam_question.question
    #redirect_back fallback_location: ediofy_root_url, notice: 'Question has been shared successfull!'
    redirect_to ediofy_group_user_exam_question_path(@exam_question, params[:group_id]), notice: 'Question has been shared successfull!'

  end

  protected

  def exam_question_params
    params.require(:user_exam_question).permit(:user_exam_id, :question_id, :position,
      :user_exam_type, selected_answer_attributes:
      [:id, :answer_id, :confidence, :difficulty, :answer_order, :not_sure, :_destroy])
  end

  def prepare_exam
    @user_exam = current_user.ediofy_user_exams.find(params[:ediofy_user_exam_id])
  end

  def prepare_exam_question
    id = params[:id].blank? ? params[:user_exam_question_id] : params[:id]
    @exam_question = @user_exam.exam_questions.find_by_position!(id)
    @parent = @exam_question.question
  end
end
