# frozen_string_literal: true

# Can be image or audio.
# media_type is cached to database for fast lookup.
class Media < ActiveRecord::Base
  default_scope -> { where(deleted: false) }

  #scope :videos, lambda{  content_type == 'video' }
  #scope :audios,  lambda{  content_type == 'audio' }
  include ActionView::Helpers::AssetUrlHelper
  # after_update :delete_viewed_history, if: lambda{|c| c.deleted_changed? && c.deleted}
  include Groupable
  include Notifiable
  include Scorable
  include OembedProvidable

  SUBMIT_POINTS = 20
  SUBMIT_CPD_TIME = 15 * 60
  VOTE_CPD_TIME = 5 * 60

  ## The order of this hash is important, smallest to largest, ALWAYS!
  IMAGE_SIZES = {
    thumb: [40, 40],
    small: [142, 85],
    medium: [263, 156],
    large: [748, 540]
  }.freeze

  ## This does two things:
  ## 1. it defines image sizes for 2 screenshots of the video
  ## 2. it defines max_widths for video oembed
  ## ATTN. heights for oembed are calculated based on this width/aspectratio
  VIDEO_SIZES = {
    thumb: [40, 40],
    small: [142, 85],
    medium: [263, 156],
    large: [750, 420]
  }.freeze
  scope :this_week, -> { where('media.created_at > ?', Time.now.beginning_of_week) }
  scope :this_month, -> { where('media.created_at > ?', Time.now.beginning_of_month) }

  paginates_per 32
  enum status: %i[reported displayed removed]

  belongs_to :user
  belongs_to :group, foreign_key: 'posted_as_group'
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable
  has_many :media_files, dependent: :destroy
  has_many :questions, through: :media_files
  has_many :user_collections_objects, as: :objectable
  has_many :user_collections, through: :user_collections_objects
  has_many :references, dependent: :destroy, as: :referenceable
  has_many :viewed_histories, as: :viewable, dependent: :destroy
  has_many :votes, as: :votable
  has_one :default_placeholder, as: :placeholderable, dependent: :destroy

  has_many :playlist_contents, as: :playable
  has_many :playlists, through: :playlist_contents
  has_and_belongs_to_many :groups

  accepts_nested_attributes_for :references, allow_destroy: true, reject_if: proc { |ref| ref['url'].blank? && ref['title'].blank? }
  accepts_nested_attributes_for :media_files, allow_destroy: true

  acts_as_votable cacheable_strategy: :update_columns
  acts_as_commentable
  acts_as_taggable
  validates_associated :references
  validates :user, :title, :description, :media_files, presence: true

  def self.taggings_query(user_id, type = nil)
    <<-SQL
      SELECT
        m.id,
        'media' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(m.title, ''))) AS textsearch,
        m.created_at,
        m.cached_votes_up,
        m.comments_count,
        m.view_count
      FROM media m
      LEFT JOIN (
        SELECT
          media_id,
          (
            CASE
              WHEN COUNT(media_type = 'audio' OR NULL) > 0 THEN 'audio'
              WHEN COUNT(media_type = 'video' OR NULL) > 0 THEN 'video'
              WHEN COUNT(media_type = 'pdf' OR media_type = 'application' OR NULL) > 0 THEN 'pdf'
              WHEN COUNT(media_type = 'image' OR NULL) > 0 THEN 'image'
            END
          ) AS media_type
        FROM media_files
        GROUP BY media_id
      ) mf ON mf.media_id = m.id
      LEFT JOIN taggings tg ON tg.taggable_type = 'Media' AND tg.taggable_id = m.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = m.user_id
      LEFT JOIN groups_media gmed ON gmed.media_id = m.id
      LEFT JOIN group_memberships gmemb ON gmemb.group_id = gmed.group_id AND gmemb.member_id = #{user_id}
      WHERE
        m.deleted = FALSE
        AND (
          m.group_exclusive = FALSE
          OR gmemb.id IS NOT NULL
        )
        AND u.is_active = TRUE
        #{'--' if type.blank?} AND mf.media_type = '#{type}'
      GROUP BY m.id
    SQL
  end

  def self.popular_query(user_id, type = nil)
    <<-SQL
      SELECT
        m.id,
        'media' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(m.title, ''))) AS textsearch,
        m.created_at,
        m.cached_votes_up,
        m.comments_count,
        m.view_count
      FROM media m
      LEFT JOIN (
        SELECT
          media_id,
          (
            CASE
              WHEN COUNT(media_type = 'audio' OR NULL) > 0 THEN 'audio'
              WHEN COUNT(media_type = 'video' OR NULL) > 0 THEN 'video'
              WHEN COUNT(media_type = 'pdf' OR media_type = 'application' OR NULL) > 0 THEN 'pdf'
              WHEN COUNT(media_type = 'image' OR NULL) > 0 THEN 'image'
            END
          ) AS media_type
        FROM media_files
        GROUP BY media_id
      ) mf ON mf.media_id = m.id
      LEFT JOIN taggings tg ON tg.taggable_type = 'Media' AND tg.taggable_id = m.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = m.user_id
      LEFT JOIN groups_media gmed ON gmed.media_id = m.id
      LEFT JOIN group_memberships gmemb ON gmemb.group_id = gmed.group_id AND gmemb.member_id = #{user_id}
      WHERE
        m.deleted = FALSE
        AND u.is_active = TRUE
        #{'--' if type.blank?} AND mf.media_type = '#{type}'
      GROUP BY m.id
    SQL
  end

  def content_type
    files_types = media_files.pluck(:media_type).uniq
    if files_types.include? 'audio'
      'audio'
    elsif files_types.include? 'video'
      'video'
    elsif files_types.include?('pdf') || files_types.include?('application')
      'pdf'
    else
      'image'
    end
  end

  def images
    media_files.where(media_type: 'image')
  end

  def self.popular(limit = 10)
    order('score DESC').limit(limit)
  end

  def vote_by(args = {})
    super args
    user = args[:voter] unless args[:voter].nil?
    if user.present?
      relation = { media: ['Media', id] }.to_yaml
      if user.activities.where('relation_ids = ? AND key = ?', relation, 'media.vote').count === 0
        user.activity! 'media.vote', media: self, default_points: 10, default_cpd_time: VOTE_CPD_TIME
      end
    end

    try(:update_score!)
  end

  def unvote(args = {})
    super args
    try(:update_score!)
  end

  def questions_count
    question_media_count
  end

  def video_count
    count = 0
    files_types = media_files.pluck(:media_type).uniq
      if files_types.include? 'video'
        count = count + 1
    end
    count
  end


  def audio_count
    count = 0
    files_types = media_files.pluck(:media_type).uniq
      if files_types.include? 'audio'
        count = count + 1
    end
    count
  end


  def shareable_to_groups
   !group_exclusive  &&
     ( self.groups.first.present? ? 
        self.groups.first.ispublic? 
      : 
      true
     )
  end


  def self.visible_to(user)
    if user
      memid = user.id
      joins(:media_files).where('media.private = ? OR media.user_id = ?', false, memid)
    else
      joins(:media_files).where(private: false)
    end
  end

  def playlist_image
    url = "'ediofy/video-processing-message.png'"
    if self.images.blank?
      if self.content_type == "video"
        videofile = self.media_files.where(media_type: "video").first
        url = videofile.processed ? videofile.video_thumb_url : image_url(default_placeholder('Media', self.id, 'small'))
      elsif self.content_type == "audio"
       url =  image_url('ediofy/small-audio.png')
      elsif self.content_type == "pdf"
        url =  image_url('ediofy/small-pdf.png')
      else
       url = image_url(default_placeholder('Media', self.id, 'small'))
      end
    else
      url   =  self.images.first.small_url
    end
    url = url.match(/\s/) ? URI.encode(url) : url
    url
  end


  private
    def delete_viewed_history
      viewed_histories.destroy_all
    end
end


