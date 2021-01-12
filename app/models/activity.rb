class Activity < ActiveRecord::Base
  paginates_per 15

  belongs_to :user
  after_create :rollup_activity

  serialize :variables
  serialize :relation_ids

  before_save :extract_relations_from_variables, :update_relation_ids

  has_ancestry({orphan_strategy: :adopt})

  def self.users_activity
    roots.select('DISTINCT ON(activities.user_id) *').
      order('activities.user_id, activities.created_at DESC').
      joins{user.setting}.
      where{user.setting.privacy_public <= Setting::PRIVACY_MEDIUM}.
      limit(10)
  end

  def to_s
    I18n.t key, variables.merge(relations).merge(user: user, scope: "activities", count: (child_ids.count+1))
  end

  def variables
    super || {}
  end

  def relation_ids
    super || {}
  end

  def relations
    @relations ||= Hash[relation_ids.map do |key, (klass, id)|
      begin
        [key, klass.constantize.find(id)]
      rescue ActiveRecord::RecordNotFound
        [key, nil]
      end
    end || {}]
  end

  attr_writer :relations

protected

  def rollup_old_activity
    intime = created_at-30.minutes
    inid = self.id
    alike_activity = Activity.where(key: self.key).where(user_id: user).where{(created_at.gt intime) & (id.not_eq inid)}.last
    if alike_activity
      alike_activity.parent = self
      alike_activity.save
    end
  end

  def rollup_activity
    intime = 15.minutes.ago
    inid = self.id
    alike_activity = Activity.where(key: self.key).where(user_id: user).where("created_at > ? AND id != ?", intime, inid).last
    if alike_activity
      alike_activity.parent = self
      alike_activity.save
    end
  end

  def extract_relations_from_variables
    extracted_relations, self.variables = variables.partition { |key, value| value.is_a? ActiveRecord::Base }.map { |tuples| Hash[tuples] }
    relations.merge! extracted_relations if extracted_relations.present?
  end

  def update_relation_ids
    self.relation_ids = Hash[relations.map do |key, value|
      unless value.nil?
        [key, [value.class.to_s, value.id]]
      end
    end]
  end
end
