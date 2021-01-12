class Ediofy::QuestionsController < EdiofyController
  include PlaylistsHelper

  helper 'ediofy/exam'

  before_action :set_question, only: %i[destroy show edit add_to_playlist update answer duplicate add_to_user_collection remove_from_user_collection share_to_group]
  before_action :load_user_collection, only: :remove_from_user_collection
  before_action :prepare_user_collection, only: :add_to_user_collection
  before_action :check_authorization, only: [:edit, :update, :destroy]

  def show
    save_view_history(@question)
    @images = @question.images
    @answered_count = @question.selected_answers.count
    @comments = @question.comments.where(parent_id: nil).approved
    ids = @comments.select(:id)
    @comment_references = Reference.joins(:comment).where(referenceable_id: ids, comments: {status: 'approved'} ).limit(5)

    @newly_created_question = (request.env['HTTP_REFERER'] == new_ediofy_question_url)
    # Its instantiating the object so formatastic has the correct model in it

    find_playlist_from_params
    find_playlist_links(@question)
    respond_with @question
  end

  def new
    if params[:question].present?
      @question = Question.new(question_params)
    else
      @question = Question.new()
    end
    @question.answers.build(correct: true)
    @question.answers.build(correct: false)
    @question.references.build
    @cpd_point = ActivityKeyPointValue['question.submit']&.cpd_time
  end

  def create
    @question = current_user.questions.new(question_params)
    @question.approved = true
    if @question.save
      if params[:group_id]
        Group.find(params[:group_id]).questions << @question
        @question.update(group_exclusive: true)
        @question.update(posted_as_group: params[:group_id]) if params[:question][:posted_as_group] == "true"
      end
      path = params[:group_id].present? ? ediofy_group_question_path(@question,  :group_id => params[:group_id]) : ediofy_question_path(@question)
      redirect_to path, notice: "Question created successfully"
    else
      initialize_nested
      @question.references.build if @question.references.empty?
      render :new
    end
  end

  def edit
    initialize_nested
    @question.references.build if @question.references.empty?
    respond_with @question
  end

  def update
    if @question.update(question_params.except(:posted_as_group))
      if @question.group_exclusive?
        @question.groups << Group.find(params[:group_id]) unless @question.groups.where(id: params[:group_id]).exists?
      end

      redirect_to ediofy_question_path(@question)
    else
      @question.references.build if @question.references.empty?
      render :edit
    end
  end

  def add_to_user_collection
    unless @user_collection.questions.include? @question
      @user_collection.questions << @question
    end
    respond_with @question, location: [:ediofy, @question]
  end

  def remove_from_user_collection
    @user_collection.questions.delete @question
    respond_with @question, location: [:ediofy, @question]
  end

  def answer
    exam_params = {
      exam_mode: '1',
      tag_list: @question.tags.pluck(:name).join(",")
    }
    @exam = current_user.ediofy_user_exams.build(exam_params)
    @exam.exam_questions.build(question: @question)
    @exam.save
    redirect_to ediofy_user_ediofy_user_exam_user_exam_question_path(@exam.id, @exam.exam_questions.first.position, playlist: params.include?(:playlist) ? params[:playlist] : nil)
  end

  def duplicate
    duplicate_from_id = @question.id
    @question = @question.amoeba_dup
    @question.duplicate_from_id = duplicate_from_id
    @question.user_id = current_user.id
    @cpd_point = ActivityKeyPointValue['question.duplicate']&.cpd_time
    render action: :new
  end

  def destroy
    if @question.destroy
      redirect_to user_root_path, notice: "Question has been deleted successfull!"
    else
      redirect_to edit_ediofy_question_path(@question), alert: @conversation.errors.full_messages.first
    end
  end

  def share_to_group
    Group.find(params[:group_id]).questions << @question
    redirect_to ediofy_group_question_path(@question, params[:group_id]), notice: 'Question has been shared successfull!'
  end




  private

  def question_params
    params.require(:question).permit(:duplicate_from_id, :title, :body,
                                     :explanation, :difficulty, :private, :tag_list, :all_comments, :group_id, :group_exclusive, :posted_as_group,
                                     answers_attributes: [:correct, :id, :body, :_destroy],
                                     references_attributes: [:id, :title, :url, :_destroy],
                                     images_attributes: [:file, :s3_file_name, :s3_file_url, :position, :id, :_destroy],
                                     media_file_ids: []
    )
  end

  def set_question
    @question = @parent = Question.find_by(id: params[:id])
    @show_all_comments = params["show_all"] == "true"
    if @question.blank?
      redirect_back_or_default({alert: "Question not found"}, nil)
    end
  end

  def initialize_nested
    @question.correct_answers.build if @question.correct_answers.empty?
    @question.incorrect_answers.build if @question.incorrect_answers.empty?
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

  def check_authorization
     if @question.user.id != current_user.id
      redirect_back_or_default({alert: "You are not authorized to perform this action"}, ediofy_question_path(@question))
    end
  end
end


