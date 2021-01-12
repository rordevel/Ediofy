# frozen_string_literal: true

class Conversation < ActiveRecord::Base
  include Groupable
  include Notifiable
  include Scorable

  VOTE_CPD_TIME = 5 * 60

  paginates_per 15
  enum status: %i[reported displayed removed]

  default_scope -> { where(deleted: false) }
  belongs_to :user
  belongs_to :group, foreign_key: 'posted_as_group'
  has_many :reports, as: :reportable
  has_many :viewed_histories, as: :viewable
  has_many :images, as: :imageable
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable
  has_many :users, through: :comments
  has_many :viewed_histories, as: :viewable, dependent: :destroy
  has_one :default_placeholder, as: :placeholderable, dependent: :destroy
  has_and_belongs_to_many :groups
  has_many :playlist_contents, as: :playable
  has_many :playlists, through: :playlist_contents

  validates :title, :description, presence: true

  # after_update :delete_viewed_history, if: lambda{|c| c.deleted_changed? && c.deleted}
  after_create_commit :new_activity

  acts_as_taggable
  acts_as_votable cacheable_strategy: :update_columns
  accepts_nested_attributes_for :images, allow_destroy: true

  def self.taggings_query(user_id)
    <<-SQL
      SELECT
        c.id,
        'conversations' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(c.title, ''))) AS textsearch,
        c.created_at,
        c.cached_votes_up,
        c.comments_count,
        c.view_count
      FROM conversations c
      LEFT JOIN taggings tg ON tg.taggable_type = 'Conversation' AND tg.taggable_id = c.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = c.user_id
      LEFT JOIN conversations_groups cg ON cg.conversation_id = c.id
      LEFT JOIN group_memberships gm ON gm.group_id = cg.group_id AND gm.member_id = #{user_id}
      WHERE
        c.deleted = FALSE
        AND (
          c.group_exclusive = FALSE
          OR gm.id IS NOT NULL
        )
        AND u.is_active = TRUE
      GROUP BY c.id
    SQL
  end

  def self.popular_query(user_id)
    <<-SQL
      SELECT
        c.id,
        'conversations' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(c.title, ''))) AS textsearch,
        c.created_at,
        c.cached_votes_up,
        c.comments_count,
        c.view_count
      FROM conversations c
      LEFT JOIN taggings tg ON tg.taggable_type = 'Conversation' AND tg.taggable_id = c.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = c.user_id
      LEFT JOIN conversations_groups cg ON cg.conversation_id = c.id
      LEFT JOIN group_memberships gm ON gm.group_id = cg.group_id AND gm.member_id = #{user_id}
      WHERE
        c.deleted = FALSE
        AND u.is_active = TRUE
      GROUP BY c.id
    SQL
  end

  def vote_by(args = {})
    super args
    user = args[:voter] unless args[:voter].nil?
    if user.present?
      relation = { conversation: ['Conversation', id] }.to_yaml
      if user.activities.where('relation_ids = ? AND key = ?', relation, 'conversation.vote').count === 0
        user.activity! 'conversation.vote', conversation: self, default_points: 10, default_cpd_time: VOTE_CPD_TIME
      end
    end

    try(:update_score!)
  end

  def playlist_image
    if images.any?
      images.first.large_url
    else
      'ediofy/ediofy-placeholder.png'
    end
  end

  protected

  def new_activity
    user.activity! 'conversation.new', conversation: self, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'conversation.new')&.cpd_time
  end

  private

  def delete_viewed_history
    viewed_histories.destroy_all
  end
end
