# Store the points and time value that should be granted for each activity key.
class ActivityKeyPointValue < ActiveRecord::Base
  CATEGORIES = ['learning', 'teaching'].freeze

  # after_save :delete_index_cache
  # after_destroy :delete_index_cache

  validates :point_value, :cpd_time, numericality: {greater_than_or_equal_to: 0}
  validates :category, inclusion: { in: CATEGORIES }, :allow_blank => true

  scope :enabled, -> { where(enabled: true) }
  scope :learning, -> { where(category: 'learning') }
  scope :teaching, -> { where(category: 'teaching') }

  # def self.index_cache_key_for activity_key
  #   "#{model_name.cache_key}[#{activity_key}]"
  # end

  def self.[] activity_key, default=0, default_cpd_time=0
    activity_key = activity_key.to_s
    # Rails.cache.fetch index_cache_key_for(activity_key) do
    #   obj = find_by(activity_key: activity_key)
    #   if obj.blank?
    #     create(activity_key: activity_key, point_value: default || 0, cpd_time: default_cpd_time || 0)#.point_value
    #   else
    #     obj#.point_value
    #   end
    # end
    obj = find_by(activity_key: activity_key, enabled: true)
    # if obj.blank?
    #   create(activity_key: activity_key, point_value: default || 0, cpd_time: default_cpd_time || 0)
    # else
    #   obj
    # end
    obj
  end

#   def index_cache_key
#     self.class.index_cache_key_for activity_key
#   end

# protected

#   def delete_index_cache
#     Rails.cache.delete index_cache_key
#   end
end
