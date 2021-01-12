class QuestionsVotedBadgeObserver < ActiveRecord::Observer
  observe ActsAsVotable::Vote

  def after_create vote
    if vote.voter.is_a? User and vote.votable.is_a? Question
      user = vote.voter
      count = user.votes.blank? ? 0 : user.votes.for_type("Question").count
      QuestionsVotedBadge.not_held_by(user).where("value <= ?", count).order("value asc").find_each do |badge|
        user.badge! badge, count: badge.value
      end
    end
  end
end
