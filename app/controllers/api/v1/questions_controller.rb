module Api
  module V1
    class QuestionsController < ApiController
      before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :add_media, :upvote, :downvote, :novote, :answer, :report]
      before_action :set_question, only: [:show, :answer, :upvote, :downvote, :novote, :report]

      resource_description{ resource_id "questions"}

      api :GET, "/questions", "Questions list"
      param :query, String, desc: "Search Keywords"
      param :order_by, String, desc: "created_at, score"
      param :direction, String, desc: "desc, asc"
      def index
        @query = params[:query] || ""
        @order_by = params[:order_by]
        @direction = params[:direction]
        @limit = params[:limit]
        @questions = Question.advanced_localized_search query: @query,
                                                        limit: @limit,
                                                        order_by: @order_by,
                                                        direction: @direction,
                                                        user: current_user

        @questions = @questions.page params[:page]
      end

      api :GET, "/questions/:id", "Show Question"
      def show
        
      end

      api :POST, "/questions/:id/upvote"
      def upvote
        @question.vote_up current_user
        render :show
      end

      api :POST, "/questions/:id/downvote"
      def downvote
        @question.vote_down current_user
        render :show
      end

      api :POST, "/questions/:id/novote"
      def novote
        @question.unvote voter: current_user
        render :show
      end

      api :GET, "/questions/:id/answer", "Get options to select for answer"
      def answer
        exam_params = {
          exam_mode: '1',
          tag_ids: @question.tags.map{|t| t.id.to_s }
        }
        @exam = current_user.ediofy_user_exams.build(exam_params)
        @exam.exam_questions.build(question: @question)
        @exam.save
        @exam_question = @exam.exam_questions.first
        @question             = @exam_question.question
        @answers              = @question.sorted_answers("#{current_user.email}#{@exam.id}")
        @selected_answer      = @exam_question.selected_answer
      end

      api :POST, "/questions/:id/report", "Report a question"
      param :reason, String, required: true, desc: "Offensive, Inappropriate, Spam, Other"
      param :comments, String, desc: "Report comments"
      def report
        @question_report = @question.reports.by(current_user).create(question_report_params)
      end



      private
      def set_question
        @question = Question.find params[:id]
      end
      def question_report_params
        params.require(:report).permit(:reason, :comments) 
      end
    end
  end
end