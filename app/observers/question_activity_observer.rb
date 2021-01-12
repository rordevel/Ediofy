class QuestionActivityObserver < ActiveRecord::Observer
  observe :question

  def after_create question
    if question.user != nil
      if !question.parent
        if question.duplicate_from_id.present?
          question.user.activity! 'question.duplicate', cpd_time: ActivityKeyPointValue.find_by(activity_key: 'question.duplicate')&.cpd_time, question: question
        else
          question.user.activity! 'question.submit', default_points: Question::SUBMIT_POINTS, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'question.submit')&.cpd_time, question: question
        end
      end
    end
  end
end
