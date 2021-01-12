# TODO not being used in BETA
class Badge < ActiveRecord::Base
  has_many :badge_users, dependent: :destroy
  has_many :users, through: :badge_users

  validates_presence_of :name

  mount_uploader :image, BadgeImageUploader

  # Make sure we route all badge classes as "badges"
  # Integration tests will cover this.
  def self.inherited subclass
    super
    subclass.model_name.instance_variable_set :@route_key, model_name.route_key
    subclass.model_name.instance_variable_set :@singular_route_key, model_name.singular_route_key
  end

  def self.not_held_by user
    # XXX: Make into a null-check on an outer join?
    where("(SELECT COUNT(*) FROM badge_users WHERE badge_id = badges.id AND user_id = ?) = 0", user.id)
  end

  # Yes, this uses inflection—but it's for administrators only.
  def self.human_type
    model_name.human.titleize
  end

  delegate :human_type, to: "self.class"

  def to_s
    name
  end
end