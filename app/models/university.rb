# TODO not in BETA
class University < ActiveRecord::Base
  # attr_accessible :abbreviation, :name, :badge, :website, :country
  has_many :users, foreign_key: :university_group_id

  has_many :questions, through: :users
  has_many :user_collections, through: :users
  has_many :media_collections, through: :users
  has_many :media, through: :users
  has_many :points, through: :users
  has_many :activities, through: :users

  validates_presence_of :name

  mount_uploader :badge, BadgeImageUploader

  def self.advanced_search(arguments = {})
    query = arguments[:query] || ""
    # query = query.split(/[, ]/).map!{ |q| "%#{q}%" } if query.present?
    order_by = %w(name users_count rating created_at).include?(arguments[:order_by]) ? arguments[:order_by] : 'rating'
    direction = %w(asc desc).include?(arguments[:direction]) ? arguments[:direction] : 'desc'

    ## universites_points is a view
    # CREATE VIEW universities_points AS
    #   SELECT
    #     u.id AS university_id,
    #     COALESCE(SUM(p.value),0) AS points
    #   FROM
    #     universities u
    #   LEFT OUTER JOIN
    #     users m
    #   ON
    #     m.university_group_id = u.id
    #   LEFT OUTER JOIN
    #     points p
    #   ON
    #     m.id=p.user_id
    #   GROUP BY
    #     u.id;

    universities = University.select("universities.*, up.points as rating")
                             .joins('LEFT JOIN universities_points up ON universities.id=up.university_id')
    if query.present?
      # universities = universities.where{ name.like_all(query) | abbreviation.like_any(query) }
      universities = universities.where(" name ilike '%#{query}%' OR abbreviation ilike '%#{query}' ")
    else
      universities = universities.where("users_count > ?", 0)
    end
    universities.order("#{order_by} #{direction}")
  end

  def to_s
    name
  end

  def rating
    points.sum(:value).to_i
  end

end
