class CpdTime < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity

  validates :activity, presence: true
  validates :value, presence: true, numericality: true
  validates_each :user do |record, attribute, value|
    if record.activity.try(:user) and record.user != record.activity.user
      record.errors.add :user, "must be the same as activity user"
    end
  end

  scope :enabled, -> { includes(:activity).where(activities: {key: ActivityKeyPointValue.enabled.pluck(:activity_key)}) }
  scope :learning, -> { includes(:activity).where(activities: {key: ActivityKeyPointValue.learning.pluck(:activity_key)}) }
  scope :teaching, -> { includes(:activity).where(activities: {key: ActivityKeyPointValue.teaching.pluck(:activity_key)}) }

  def self.total
    sum(:value)
  end

  CONTRIBUTIONS_ACTIVITY_KEYS = ["question.submit", "media.new", "link.new", "media_files.new", "conversation.new"]

  def self.contributions
    select("sum(value) as value").joins(:activity).where("activities.key IN(?)", CONTRIBUTIONS_ACTIVITY_KEYS)
  end

  # def self.learning
  #   select("sum(value) as value").joins(:activity).where("activities.key NOT IN(?)", CONTRIBUTIONS_ACTIVITY_KEYS)
  # end

  def category
    ActivityKeyPointValue.find_by(activity_key: activity.key)&.category
  end
end
