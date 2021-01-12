class Point < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity

  validates :activity, presence: true
  validates :value, presence: true, numericality: true
  validates_each :user do |record, attribute, value|
    if record.activity.try(:user) and record.user != record.activity.user
      record.errors.add :user, "must be the same as activity user"
    end
  end

  def self.this_week
    where ["created_at BETWEEN ? AND ?", Time.zone.now.beginning_of_week, Time.zone.now.end_of_week]
  end

  def self.this_month
    where ["created_at BETWEEN ? AND ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month]
  end

  def self.total
    sum(:value)
  end

  # XXX: Should these truncates be time zone aware?

  def self.per_day
    select("sum(value) as value, date_trunc('day', created_at) || ' GMT' as period").group("period").order("period")
  end

  def self.per_week
    select("sum(value) as value, date_trunc('week', created_at) || ' GMT' as period").group("period").order("period")
  end

  def self.per_month
    select("sum(value) as value, date_trunc('month', created_at) || ' GMT' as period").group("period").order("period")
  end

  def self.past_7_days
    where("created_at >= ?", 7.days.ago.beginning_of_day)
  end

  def self.past_4_weeks
    where("created_at >= ?", 4.weeks.ago.beginning_of_day)
  end

  def self.past_year
    where("created_at >= ?", 1.year.ago.beginning_of_day)
  end
end
