class Link < ApplicationRecord
  include Groupable
  include Notifiable

  default_scope -> { where(deleted: false) }
  paginates_per 15
  enum status: [:reported, :displayed, :removed]
  include Scorable
  VOTE_CPD_TIME = 5 * 60

  belongs_to :user
  belongs_to :group, :foreign_key => 'posted_as_group'
  validates :url,:description, :title, presence: true
  validates :url, :format => { :with => URI::regexp(%w(http https)), :message => "Valid URL required"}

  has_many :viewed_histories, as: :viewable, dependent: :destroy
  has_many :images, as: :imageable
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :reports, as: :reportable
  has_one :default_placeholder, as: :placeholderable, dependent: :destroy

  has_many :playlist_contents, as: :playable
  has_many :playlists, through: :playlist_contents

  has_and_belongs_to_many :groups
  accepts_nested_attributes_for :images, allow_destroy: true
  # after_update :delete_viewed_history, if: lambda{|c| c.deleted_changed? && c.deleted}

  after_create_commit :new_activity

  acts_as_taggable
  acts_as_votable cacheable_strategy: :update_columns

  def self.taggings_query(user_id)
    <<-SQL
      SELECT
        l.id,
        'links' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(l.title, ''))) AS textsearch,
        l.created_at,
        l.cached_votes_up,
        l.comments_count,
        l.view_count
      FROM links l
      LEFT JOIN taggings tg ON tg.taggable_type = 'Link' AND tg.taggable_id = l.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = l.user_id
      LEFT JOIN groups_links gl ON gl.link_id = l.id
      LEFT JOIN group_memberships gm ON gm.group_id = gl.group_id AND gm.member_id = #{user_id}
      WHERE
        l.deleted = FALSE
        AND (
          l.group_exclusive = FALSE
          OR gm.id IS NOT NULL
        )
        AND u.is_active = TRUE
      GROUP BY l.id
    SQL
  end

  def self.popular_query(user_id)
    <<-SQL
      SELECT
        l.id,
        'links' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(l.title, ''))) AS textsearch,
        l.created_at,
        l.cached_votes_up,
        l.comments_count,
        l.view_count
      FROM links l
      LEFT JOIN taggings tg ON tg.taggable_type = 'Link' AND tg.taggable_id = l.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = l.user_id
      LEFT JOIN groups_links gl ON gl.link_id = l.id
      LEFT JOIN group_memberships gm ON gm.group_id = gl.group_id AND gm.member_id = #{user_id}
      WHERE
        l.deleted = FALSE
        AND u.is_active = TRUE
      GROUP BY l.id
    SQL
  end

  def vote_by(args = {})
    super args
    user = args[:voter] unless args[:voter].nil?
    if user.present?
      relation = { :link => ["Link",self.id] }.to_yaml
      if user.activities.where( "relation_ids = ? AND key = ?", relation, 'link.vote' ).count === 0
        user.activity! 'link.vote', link: self, default_points: 10, default_cpd_time: VOTE_CPD_TIME
      end
    end
    try(:update_score!)
  end

  def playlist_image
    if page_image.present?
      page_image
    else
      if images.any?
        images.first.large_url
      else
        'ediofy/ediofy-placeholder.png'
      end
    end
  end

  protected

  def new_activity
    user.activity! 'link.share', link: self, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'link.share')&.cpd_time
  end

  private

  def delete_viewed_history
    self.viewed_histories.destroy_all
  end
end
