class QuestionsSubmittedBadgeObserver < ActiveRecord::Observer
  observe :question

  def after_create question
    if question.user
      user = question.user
      count = user.questions.count
      QuestionsSubmittedBadge.not_held_by(user).where("value <= ?", count).order("value asc").find_each do |badge|
        user.badge! badge, count: badge.value
      end
    end
  end
end
