class LevelBadge < Badge
  validates :value, presence: true, numericality: {greater_than: 0}
end
