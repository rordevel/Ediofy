module Actable
  extend ActiveSupport::Concern

  included do
    has_many :activities, dependent: :destroy
  end

  # Creates a new activity for this actor
  #
  # First argument should be an i18n-like key, like "question.answered" or
  # "user.registered". This is used to translate the activity text and must
  # be present in i18n as "activities.<key>". This can instead be passed in
  # the variables as `key`.
  #
  # Following should be a hash of variables to be interpolated into the
  # activity's description. They can be ActiveRecord models which will be
  # saved efficiently as a type/id pair.
  #
  # From these variables a few options are pulled:
  #
  #  * points: A number of points to grant for this particular actvity. This
  #    is not overridden. Used by badges, for instance.
  #
  #  * default_points: A number of points to grant for this type of activity.
  #    This will be stored in ActivityKeyPointValue as the default and can be
  #    edited by the administrator.
  #
  def activity! *args
    variables = args.extract_options!
    key = args.shift || variables.delete(:key) || raise(ArgumentError, "missing key")
    default_points = variables.delete(:default_points) || 0
    default_cpd_time = variables.delete(:default_cpd_time) || 0

    variables[:points] ||= ActivityKeyPointValue[key, default_points, default_cpd_time]&.point_value || 0
    variables[:cpd_time] ||= ActivityKeyPointValue[key, default_points, default_cpd_time]&.cpd_time || 0
    variables.delete :points unless variables[:points] > 0
    variables.delete :cpd_time unless variables[:cpd_time] > 0

    activities.create!(key: key.to_s, variables: variables).tap do |activity|
      points.create! value: variables[:points], activity: activity if variables[:points]
      cpd_times.create! value: variables[:cpd_time], activity: activity if variables[:cpd_time]
    end
  end

  def recent_activities
    @activities = Activity.roots.where(user_id: id)
  end

  def friends_recent_activities
    friend_ids = friends ? friends.map(&:id) : [ ]
    @activities = Activity.roots.where(user_id: friend_ids).
                    joins{user.setting}.
                    where{user.setting.privacy_friends <= 4}
  end
end
