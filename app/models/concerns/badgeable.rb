module Badgeable
  extend ActiveSupport::Concern

  included do
    has_many :badge_users, dependent: :destroy
    has_many :badges, through: :badge_users
  end

  def badge! badge, *args
    variables = args.extract_options!
    key = args.shift || variables.delete(:key) || badge.name.parameterize.underscore || raise(ArgumentError, "missing key")

    unless badges.include? badge
      badge_users.create! badge: badge, reason_key: key.to_s, reason_variables: variables
    end
  end
end
