class UserCollection < ActiveRecord::Base

  paginates_per 32

  belongs_to :user
  has_many :user_collections_objects

  has_many :media, through: :user_collections_objects, source: :objectable, source_type: 'Media'#, uniq: true
  has_many :questions, through: :user_collections_objects, source: :objectable, source_type: 'Question'#, uniq: true

  scope :this_week, -> { where('user_collections.created_at > ?', Time.now.beginning_of_week) }
  scope :this_month, -> { where('user_collections.created_at > ?', Time.now.beginning_of_month) }

  validates :user, :title, :description, presence: true

  def self.visible_to user
    if user
      memid = user.id
      where("private = ? OR user_id = ? ", false, memid)
    else
      where(private: false)
    end
  end

  def to_s
    title
  end

  def self.advanced_search arguments = {}
    query = arguments[:query] || ""
    # query = query.split(/[, ]/).map!{ |q| "%#{q}%" }
    limit = %w(all mine friends).include?(arguments[:limit]) ? arguments[:limit] : "all"
    order_by = %w(title, score created_at).include?(arguments[:sort]) ? arguments[:sort] : 'created_at'
    direction = %w(asc desc).include?(arguments[:direction]) ? arguments[:direction] : 'desc'
    user = arguments[:user]

    relation = visible_to user

    if query.present?
      relation = relation.where(" title ilike '%#{query}%' OR description ilike '%#{query}' ")
    end

    if limit != "all" && user.present?
      case limit
      when "mine"
        ids = user.id
      when "friends"
        ids = user.friends.map(&:id)
      end
      relation = relation.where user_id: ids
    end

    relation.order("#{order_by} #{direction}")
  end

end
