class PointsBadgeObserver < ActiveRecord::Observer
  observe :point

  def after_create point
    user = point.user
    total_points = user.points.total
    PointsBadge.not_held_by(user).where("value <= ?", total_points).each do |badge|
      user.badge! badge, points: badge.points
    end
  end
end
