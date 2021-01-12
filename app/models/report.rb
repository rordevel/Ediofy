class Report < ActiveRecord::Base
  belongs_to :reportable, polymorphic: true
  belongs_to :user

  validates :reportable, :user, :reason, presence: true
  validates :reportable_id, uniqueness: {scope: %i[user_id reportable_type], message: "has already been reported by you"}

  class_attribute :default_reasons
  self.default_reasons = %w(Offensive Inappropriate Spam).freeze

  after_create :send_email_notification_to_admin

  def send_email_notification_to_admin
    NotificationMailer.content_reported(AdminUser.pluck(:email), self.user, self.reportable).deliver_later unless AdminUser.blank?
  end

  def self.by user
    where(user_id: user)
  end

  def reason_other
    reason unless reason.in? default_reasons
  end

  def reason_other(value)
    self.reason = value if value.present?
  end

end

