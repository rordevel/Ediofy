# TODO not being used in BETA
class BadgeUser < ActiveRecord::Base
  belongs_to :badge
  belongs_to :user

  serialize :reason_variables
  serialize :reason_relation_ids

  before_save :extract_relations_from_variables
  before_save :update_reason_relation_ids
  after_save :create_activity
  after_save :create_notification

  default_scope -> { includes :badge }

  def self.this_week
    where ["created_at BETWEEN ? AND ?", Time.zone.now.beginning_of_week, Time.zone.now.end_of_week]
  end

  def self.this_month
    where ["created_at BETWEEN ? AND ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month]
  end

  def reason
    I18n.t reason_key, reason_variables.merge(reason_relations).merge(badge: badge, user: user, scope: "badges")
  end

  def reason_variables
    super || {}
  end

  def reason_relation_ids
    super || {}
  end

  def reason_relations
    @reason_relations ||= Hash[reason_relation_ids.map do |key, (type, id)|
      [key, type.constantize.find(id)]
    end || {}]
  end

  def reason_relations= reason_relations
    @reason_relations = reason_relations
  end

protected

  def extract_relations_from_variables
    extracted_relations, self.reason_variables = reason_variables.partition { |key, value| value.is_a? ActiveRecord::Base }.map { |tuples| Hash[tuples] }
    reason_relations.merge! extracted_relations if extracted_relations.present?
  end

  def update_reason_relation_ids
    self.reason_relation_ids = Hash[reason_relations.map do |key, value|
      [key, [value.class.to_s, value.id]]
    end]
  end

  def create_activity
    user.activity! :badge, badge: badge, badge_user: self, points: badge.points, cpd_time: badge.cpd_time
  end

  def create_notification
    user.notifications.create! image_url: badge.image.notification.url, title: I18n.t("notification.badge.#{reason_key}.title_html", { badge: badge, default: I18n.t('notification.badge.default.title_html', badge: badge) }), body: reason, links: [{title: badge.name, href: [:ediofy, badge] }]
  end
end
