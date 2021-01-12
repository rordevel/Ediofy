module Levellable
  extend ActiveSupport::Concern

  LEVEL_ACCELERATION = 20

  def level_progression
    level_for_points(points.total)
  end

  def level
    level_progression.floor
  end

  def points_for_next_level
    points_for_level(level+1)
  end

  def points_for_current_level
    points_for_level(level)
  end

  def points_to_next_level
    (points_for_next_level - points.total).to_i
  end

  def points_into_current_level
    points.total - points_for_current_level
  end

  def points_for_next_level_only
    points_for_next_level - points_for_current_level
  end

  def percent_to_next_level
    percent = (points_into_current_level / points_for_next_level_only.to_f) * 100
    percent.floor
  end

private

  def points_for_level(level_in)
    (((level_in ** 3.0) - 1.0) * LEVEL_ACCELERATION).to_i
  end

  def level_for_points(points_in)
    (((points_in + LEVEL_ACCELERATION) ** (1.0 / 3.0))/(LEVEL_ACCELERATION ** (1.0 / 3.0)))
  end
end
