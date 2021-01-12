class QuestionsAnsweredBadgeObserver < ActiveRecord::Observer
  observe :selected_answer

  def after_create selected_answer
    question = selected_answer.try(:question)
    user = selected_answer.try(:user_exam_question).try(:user_exam).try(:user)
    if user
      count = user.ediofy_selected_answers.count
      QuestionsAnsweredBadge.not_held_by(user).where("value <= ?", count).order("value asc").find_each do |badge|
        user.badge! badge, count: badge.value
      end
    end
  end
end
