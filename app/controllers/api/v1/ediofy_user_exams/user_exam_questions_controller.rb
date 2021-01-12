module Api
  module V1
    module EdiofyUserExams
      class UserExamQuestionsController < ApiController
        before_action :prepare_exam
        before_action :prepare_exam_question
        resource_description{ resource_id "Answers" }

        api :GET, "/exams/:id/questions/:position", "Selecting answer by position of the revision"
        def show
          @question             = @exam_question.question
          @answers              = @question.sorted_answers("#{current_user.email}#{@user_exam.id}")
          @selected_answer      = @exam_question.selected_answer
        end

        api :PUT, "/exams/:id/questions/:position", "Submit Answer by Selecting answer"
        param :user_exam_question, Hash, "Exam Question" do
          param :selected_answer_attributes, Hash, "Selected Answer Attributes" do
            param :answer_id, Integer, required: true
            param :confidence, String
            param :difficulty, String
          end
        end
        def update
          params[:user_exam_question][:selected_answer_attributes][:answer_order] = YAML::dump(@exam_question.question.sorted_answers(current_user.email).map(&:id))
          @exam_question.update_attributes(exam_question_params)
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
          @exam_question = @user_exam.exam_questions.find_by_position!(params[:id])
        end
      end
    end
  end
end