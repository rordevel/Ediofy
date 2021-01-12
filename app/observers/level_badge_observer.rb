class LevelBadgeObserver < ActiveRecord::Observer
  observe :point

  def after_create point
    user = point.user
    level = user.level
    LevelBadge.not_held_by(user).where("value <= ?", level).each do |badge|
      user.badge! badge, level: badge.value
    end
  end
end
