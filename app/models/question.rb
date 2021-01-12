class Question < ActiveRecord::Base
  include Groupable
  include Notifiable
  include Scorable

  default_scope -> { where(deleted: false) }
  SUBMIT_POINTS = 50
  SUBMIT_CPD_TIME = 10*60
  VOTE_CPD_TIME = 5*10
  paginates_per 10

  translates :body, :explanation
  
  belongs_to :user
  belongs_to :group, :foreign_key => 'posted_as_group'
  has_many :user_collections_objects, as: :objectable, dependent: :destroy
  has_many :user_collections, through: :user_collections_objects

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :user_exam_questions, dependent: :destroy
  has_many :answers, -> { order 'id ASC' }, dependent: :destroy
  has_many :correct_answers, ->{where(correct: true)}, dependent: :destroy, class_name: "Answer"
  has_many :incorrect_answers, ->{where(correct: false)}, dependent: :destroy, class_name: "Answer"
  has_many :selected_answers, through: :answers
  has_many :reports, as: :reportable
  has_many :images, as: :imageable
  has_many :references, dependent: :destroy, as: :referenceable
  has_many :viewed_histories, dependent: :destroy, as: :viewable
  has_and_belongs_to_many :groups
  
  has_many :playlist_contents, as: :playable
  has_many :playlists, through: :playlist_contents


  has_ancestry({orphan_strategy: :adopt})
  has_one :default_placeholder, as: :placeholderable, dependent: :destroy
  # after_update :delete_viewed_history, if: lambda{|q| q.deleted_changed? && q.deleted}
  DIFFICULTY = ["easy", "medium", "hard"]
  enum status: [:reported, :displayed, :removed]
  
  acts_as_commentable
  acts_as_votable cacheable_strategy: :update_columns
  acts_as_taggable
  scope :active, -> { where(active: true) }
  scope :approved, -> { where(approved: true) }

  accepts_nested_attributes_for :answers, :images, :incorrect_answers, :correct_answers, allow_destroy: true
  accepts_nested_attributes_for :references, allow_destroy: true, reject_if: proc { |ref| ref['url'].blank? && ref['title'].blank? }
  
  validates :body, :title, presence: true
  validates_associated :correct_answers, :incorrect_answers, :references
  validate :validates_number_of_answers
  attr_accessor :duplicate_from_id
  validate :avoid_full_copy, if: lambda { |q| q.duplicate_from_id.present? }
  amoeba do
    exclude_association :reports
    exclude_association :user_exam_questions
    exclude_association :correct_answers
    exclude_association :incorrect_answers
    exclude_association :votes_for

    # include_association :answers
    # include_association :tag_questions
    # include_association :media_questions
    # include_association :references
    # include_association :translations

    clone [
      :user_collections_objects,
      :comments
    ]
  end

  # def title
  #   body.html_safe
  # end
  
  def self.visible_to user
    if user
      memid = user.id
      where("questions.private = ? OR questions.user_id = ?", false, memid)
    else
      where(private: false)
    end
  end

  def self.avg_num_answers
    Rails.cache.fetch "avg_question_answers", expires_in: 1.day do
      scores_per_obj = gmep.joins{answers.selected_answers}.group{answers.question_id}.select('count(*) as count_all').map(&:count_all).map(&:to_i)
      scores_per_obj.inject{ |sum, el| sum + el }.to_f / scores_per_obj.size
    end
  end

  def self.last_week
    where ["created_at BETWEEN ? AND ?", 1.week.ago.beginning_of_week, 1.week.ago.end_of_week]
  end

  def self.last_month
    where ["created_at BETWEEN ? AND ?", 1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
  end

  def self.popular(limit=10)
    active.approved.order('score DESC').limit(limit)
  end

  def self.taggings_query(user_id)
    <<-SQL
      SELECT
        q.id,
        'questions' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(q.title, ''))) AS textsearch,
        q.created_at,
        q.cached_votes_up,
        q.comments_count,
        q.view_count
      FROM questions q
      LEFT JOIN taggings tg ON tg.taggable_type = 'Question' AND tg.taggable_id = q.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = q.user_id
      LEFT JOIN groups_questions gq ON gq.question_id = q.id
      LEFT JOIN group_memberships gm ON gm.group_id = gq.group_id AND gm.member_id = #{user_id}
      WHERE
        q.approved = TRUE
        AND q.status != 2
        AND (
          q.group_exclusive = FALSE
          OR gm.id IS NOT NULL
        )
        AND u.is_active = TRUE
      GROUP BY q.id
    SQL
  end

  def self.popular_query(user_id)
    <<-SQL
      SELECT
        q.id,
        'questions' AS type,
        TO_TSVECTOR(CONCAT(STRING_AGG(t.name, ' '), ' ', COALESCE(q.title, ''))) AS textsearch,
        q.created_at,
        q.cached_votes_up,
        q.comments_count,
        q.view_count
      FROM questions q
      LEFT JOIN taggings tg ON tg.taggable_type = 'Question' AND tg.taggable_id = q.id AND tg.context = 'tags'
      LEFT JOIN tags t ON t.id = tg.tag_id
      LEFT JOIN users u ON u.id = q.user_id
      LEFT JOIN groups_questions gq ON gq.question_id = q.id
      LEFT JOIN group_memberships gm ON gm.group_id = gq.group_id AND gm.member_id = #{user_id}
      WHERE
        q.approved = TRUE
        AND q.status != 2
        AND u.is_active = TRUE
      GROUP BY q.id
    SQL
  end

  def sorted_answers(seed='')
    srand Digest::MD5.digest(seed).unpack("Q").first
    collection = answers.sort_by {rand}
    srand
    collection
  end

  # Returns if the given user's locale is not english (en)
  # and there is a translation avilable for their locale.
  def translation_available?(user)
    return false if user.nil?
    return false if user.locale == I18n.default_locale.to_s
    return translation_for(user.locale).persisted?
  end

  def vote_by(args = {})
    super args
    user = args[:voter] unless args[:voter].nil?
    if user.present?
      relation = { :question => ["Question",self.id] }.to_yaml
      if user.activities.where( "relation_ids = ? AND key = ?", relation, 'question.vote' ).count === 0
        user.activity! 'question.vote', question: self, default_points: 10, default_cpd_time: VOTE_CPD_TIME
      end
    end

    try(:update_score!)
  end

  def unvote args = {}
    super args
    try(:update_score!)
  end

  def media_count
    question_media_count
  end

  def approve!
    update_attribute :approved, true
  end

  def playlist_image
    if images.any?
      images.first.large_url
    else
      'ediofy/ediofy-placeholder.png'
    end
  end

protected


  def has_at_least_one_tag
    if tags.size < 1
      errors.add :tags, "must pick at least one"
    end
  end

  def has_one_correct_answer
    if answers.select(&:correct?).length != 1
      errors.add :correct_answers, "must have only one correct answer"
    end
  end

  def has_at_least_one_incorrect_answer
    if answers.reject(&:correct?).length < 1
      errors.add :incorrect_answers, "must have at least one incorrect answer"
    end
  end
  private

  def validates_number_of_answers
    self.errors.add(:answers, "At least 2 answers are required!") if self.answers.length < 2
    self.errors.add(:answers, "At least one correct answer required") if self.answers.select{|a| a.correct}.length < 1
  end
  def avoid_full_copy
    original_question = Question.includes(:answers).find(self.duplicate_from_id)
    if (original_question.attributes.values_at('body', 'title', 'explanation') == self.attributes.values_at('body', 'title', 'explanation') &&
    self.images.collect{|i|i.s3_file_url} == original_question.images.collect{|i|i.s3_file_url} &&
    self.references.collect{|r| [r.title, r.url]} == original_question.references.collect{|r| [r.title, r.url]} &&
    self.answers.collect{|a| [a.correct, a.body]} == original_question.answers.collect{|a| [a.correct, a.body]})
      self.errors.add(:duplicate_from_id, 'No changes were made')
    end
  end
  def delete_viewed_history
    self.viewed_histories.destroy_all
  end
end