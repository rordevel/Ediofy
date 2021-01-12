class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User
  # TODO when enabling the Actable module, please also enable the activity! method calls at various places
  include Actable
  include Badgeable
  include Levellable
  include Gravatarable
  include Omniauthable
  include OembedProvidable

  acts_as_voter
  acts_as_taggable
  acts_as_taggable_on :interests
  acts_as_followable
  acts_as_follower

  AVAILABLE_LOCALES = ['en', 'de'].freeze
  DEFAULT_LOCALE = 'en'.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  enum title: [:dr, :mr, :mrs, :ms, :miss, :professor, :associate_professor, :lecturer, :senior_lecturer, :ceo, :director]
  belongs_to :specialty
  has_one :address, dependent: :destroy
  has_one :setting, dependent: :destroy
  has_many :ediofy_user_exams, dependent: :destroy
  has_many :ediofy_selected_answers, through: :ediofy_user_exams, source: :selected_answers
  has_many :question_explanations, dependent: :destroy
  # has_many :question_reports, dependent: :destroy
  has_many :points, dependent: :destroy
  has_many :cpd_times, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :media, class_name: "Media", dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :notifications, dependent: :destroy, foreign_key: "receiver_id"
  has_many :unread_notifications, -> {where(read: false)}, class_name: "Notification", foreign_key: "receiver_id"
  has_many :user_collections, dependent: :destroy
  has_many :viewed_histories, dependent: :destroy

  has_many :group_memberships, foreign_key: :member_id
  has_many :groups, through: :group_memberships
  has_many :group_invites, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :playlists, dependent: :destroy

  has_one :notification_setting, dependent: :destroy
  belongs_to :university_group, class_name: 'University', counter_cache: :users_count


  has_many :sender_follow_request, class_name: 'FollowRequest',
    foreign_key: 'follower_id'
  has_many :receiver_follow_request, class_name: 'FollowRequest',
    foreign_key: 'followee_id'

  validates :full_name, presence: true, :if => lambda { |u| !u.omniauth? && !u.new_record? && u.confirmed? && u.welcome_sent || u.profile_completed }
  validates :locale, presence: true, inclusion: { in: AVAILABLE_LOCALES }
  validates :biography, length: {maximum: 160}
  validates :avatar_choice, inclusion: {in: ["twitter", "facebook", "google", "gravatar", "current", "upload"].freeze}, allow_nil: true
  validates_uniqueness_of :email
  validates :ediofy_terms_accepted, inclusion: { in: [true], message: "You have to accept terms and condition and privacy policy" }, :unless => lambda { |u| u.omniauth? }
  before_save :fix_counter_cache, :if => ->(er) { !er.new_record? && er.university_group_id_changed? }
  after_create :check_notification_settings
  before_save :choose_avatar, if: :avatar_choice
  after_save :send_welcome, if: lambda{|u| !u.welcome_sent && u.confirmed?}
  after_destroy :remove_follows
  before_destroy :remove_groups
  before_validation :set_username, if: lambda{|u| u.username.blank? && u.profile_completed}
  mount_uploader :avatar, AvatarUploader
  validate :check_dimensions#, on: :create
  attr_accessor :login, :ediofy
  attr_writer :avatar_choice

  #serialize :twitter_auth
  serialize :facebook_auth
  #serialize :google_auth
  #serialize :linkedin_auth
  delegate :name, to: :specialty, prefix: true, allow_nil: true

  #user scopes
  scope :all_active, -> { where("ediofy_terms_accepted = true AND profile_completed = true AND ghost_mode = false") }


  def self.taggings_query(user_id)
    <<-SQL
      SELECT
        u.id,
        'users' AS type,
        TO_TSVECTOR(COALESCE(u.full_name, '')) AS textsearch,
        u.created_at
      FROM users u
      WHERE
        ediofy_terms_accepted = TRUE
        AND profile_completed = TRUE
        AND ghost_mode = FALSE
        AND u.id != #{user_id}
      GROUP BY u.id
    SQL
  end

  def set_random_password
    self.password = SecureRandom.base64(6) if password.blank?
  end
  def complete_name
    self.title.blank? ? self.full_name : self.title.capitalize + " " + self.full_name
  end
  def self.locales_collection
    AVAILABLE_LOCALES.map { |locale| [I18n.t(locale, scope: :locales), locale] }
  end

  def locale_text
    I18n.t(locale, scope: :locales)
  end



  def profile_complete
    profile_complete?
  end

  def profile_complete?
    # %w(first_name last_name email biography).all?(&self.method(:query_attribute)) and %w(hospital university).any?(&self.method(:query_attribute))
    !(full_name.blank? && title.blank? && location.blank? && specialty.blank? && qualifications.blank? && about.blank?)
  end

  def ediofy?
    ediofy_terms_accepted
  end

  def self.ediofy
    where(ediofy_terms_accepted: true)
  end

  def on_boarding_process_completed
    ediofy_terms_accepted && profile_completed && interests_selected && follows_selected
  end

  # def full_name
  #   [first_name, last_name].join(' ')
  # end

  # For now, we delegate the GMEP profile group to hospital or university
  def group
    hospital.presence || university.presence || university_group.presence
  end

  def to_s
    full_name
  end

  def address
    super || build_address
  end

  def setting
    super || create_setting
  end

  def self.signed_up_this_week
    where ["created_at BETWEEN ? AND ?", Time.zone.now.beginning_of_week, Time.zone.now.end_of_week]
  end

  def self.with_privacy privacy_choice
    joins{setting}.
    where{setting.privacy_public <= privacy_choice}
  end


  def check_notification_settings
    notification_hash = {}
    if self.notification_setting.blank?
      ns = self.create_notification_setting
      ns.attributes.except("id", "user_id", "created_at", "updated_at").each_pair{|k,v| notification_hash[k] = true}
      self.notification_setting.update(notification_hash.symbolize_keys!) unless notification_hash.empty?
    end
  end


  # When ranking becomes complex and there are well-defined leaderboards,
  # consider using https://github.com/agoragames/leaderboard

  # Rank by points
  # Adds `rank` attribute
  def self.with_ranks
    select("users.*, rank").
    where(ediofy_terms_accepted: true).
    joins(:setting).
    where("settings.privacy_public <= ?", Setting::PRIVACY_MEDIUM).
    joins "LEFT JOIN
      (SELECT users.id AS user_id, row_number() OVER (ORDER BY COALESCE(SUM(points.value), 0) DESC, users.created_at ASC) AS rank
        FROM users
        INNER JOIN settings ON settings.user_id = users.id
        LEFT OUTER JOIN points
          ON points.user_id = users.id
        WHERE users.ediofy_terms_accepted = true
        AND settings.privacy_public <= #{Setting::PRIVACY_MEDIUM}
        GROUP BY users.id, users.created_at
        ORDER BY COALESCE(SUM(points.value), 0) DESC, users.created_at ASC)
      AS ranks
      ON ranks.user_id = users.id"
  end

  # Rank by points during a period
  # Adds `rank` attribute
  def self.with_ranks_between from, to
    select("users.*, rank").
    where(["users.created_at <= ?", to]).
    where(ediofy_terms_accepted: true ).
    joins(:setting).
    where("settings.privacy_public <= ?", Setting::PRIVACY_MEDIUM).
    joins "LEFT JOIN
      (SELECT users.id AS user_id, row_number() OVER (ORDER BY COALESCE(SUM(points.value), 0) DESC, users.created_at ASC) AS rank
        FROM users
        INNER JOIN settings ON settings.user_id = users.id
        LEFT OUTER JOIN points
          ON points.user_id = users.id
            AND points.created_at BETWEEN '#{from.to_formatted_s(:db)}' AND '#{to.to_formatted_s(:db)}'
        WHERE users.created_at < '#{to.to_formatted_s(:db)}'
        AND settings.privacy_public <= #{Setting::PRIVACY_MEDIUM}
        AND users.ediofy_terms_accepted = true
        GROUP BY users.id, users.created_at
        ORDER BY COALESCE(SUM(points.value), 0) DESC, users.created_at ASC)
      AS ranks
      ON ranks.user_id = users.id"
  end

  def self.with_ranks_this_week
    with_ranks_between Time.zone.now.beginning_of_week, Time.zone.now.end_of_week
  end

  def self.with_ranks_this_month
    with_ranks_between Time.zone.now.beginning_of_month, Time.zone.now.end_of_month
  end

  [nil, "_this_week", "_this_month"].each do |suffix|
    eval <<-RUBY
      def rank#{suffix || "_all_time"}
        begin
          self.class.with_ranks#{suffix}.find(id).rank.to_i
        rescue
          0
        end
      end
    RUBY
  end

  # returns the last exam updated by the user
  def last_session
    user_exams.order('updated_at DESC').first
  end

  def recent_sessions
    user_exams.order('created_at desc').limit(2)
  end

  def private_admin_groups
    groups.ad
  end


  def submitted_explanation_for?(question)
    question_explanations.where(question_id: question.id).any?
  end

  def self.locales_collection
    AVAILABLE_LOCALES.map { |locale| [I18n.t(locale, scope: :locales), locale] }
  end

  def locale_text
    I18n.t(locale, scope: :locales)
  end

  def questions_answered_count_for(tag)
    SelectedAnswer.joins{[question.tag_questions, user_exam_question.user_exam(UserExam)]}.where{tag_questions.tag_id == tag.id}.where('user_exams.user_id' => self.id).group{questions.id}.count.count
  end

  def correct_selected_answers_for(tag)
    SelectedAnswer.joins{[answer, question.tag_questions, user_exam_question.user_exam(UserExam)]}.where{tag_questions.tag_id == tag.id}.where('user_exams.user_id' => self.id).where{answer.correct == true}
  end

  def questions_correct_count_for(tag)
    correct_selected_answers_for(tag).group{questions.id}.count.count
  end

  def twitter_avatar
    twitter_auth.info.image.sub(/_normal(.*?)\Z/, '\1') if twitter?
  end

  def facebook_avatar(size='large')
    if facebook?
      if size=='original'
        result = facebook.fql_multiquery({
          "query1" => "SELECT object_id FROM album WHERE owner = me() and type='profile'",
          "query2" => "SELECT cover_object_id FROM album WHERE object_id IN (SELECT object_id FROM #query1)"
        })
        facebook.get_picture(result['query2'][0]['cover_object_id'])
      else
        facebook_auth.info.image.sub(/type=\w+(.*)\Z/, 'type='+size+'\1')
      end
    end
  end

  def google_avatar
    if google?
      google_tmp_image = google_auth.info.image
      return google_tmp_image.sub(/_normal(.*?)\Z/, '\1') if google_tmp_image
    end
  end

  def avatar_choice
    @avatar_choice ||= avatar? ? "current" : "gravatar"
  end

  def self.advanced_search(arguments = {})
    query = arguments[:query] || ""
    query = query.split(/[, ]/).map!{ |q| "%#{q}%" } if query.present?
    order_by = %w(full_name points created_at).include?(arguments[:order_by]) ? arguments[:order_by] : 'created_at'
    direction = %w(asc desc).include?(arguments[:direction]) ? arguments[:direction] : 'desc'

    ## userpoints is a view
    # CREATE VIEW user_points AS
    #   SELECT
    #     m.id AS user_id,
    #     COALESCE(SUM(p.value),0) AS points
    #   FROM
    #     users m
    #   LEFT OUTER JOIN
    #     points p
    #   ON
    #     m.id=p.user_id
    #   GROUP BY
    #     m.id;
    ##
    users = User.select("users.*, mp.points").joins('LEFT JOIN user_points mp ON users.id=mp.user_id').ediofy
    if query.present?
      users = users.where{ full_name.like_all query }
    end
    users.order("#{order_by} #{direction}")
  end

  def send_welcome
    if self.valid? && !self.email.ends_with?('auth')
      begin
        EdiofyMailer.welcome_mail(self).deliver_later
        update_attribute('welcome_sent',true)
      rescue => error
        Rails.logger.info("[WELCOME EMAIL] Unable to send to user #{id}: #{error.to_s}")
      end
    end
  end

  # def active_for_authentication?
  #   super && self.is_active?
  # end

  def inactive_message
    'Sorry, this account has been deactivated.'
  end

  def send_confirmation_instructions
    unless self.omniauth?
      super
    end
  end

  def cpd_times_in_window
    result = cpd_times.enabled

    if (self.cpd_from != nil )
      from = self.cpd_from
    else
      from = Date.today
    end

    if (self.cpd_to != nil )
      to = self.cpd_to
    else
      to = Date.today
    end
    
      result.where(created_at: from .. to)

  end

  def has_a_pending_follow_request_from(follower)
    FollowRequest.where(:follower_id => follower.id, :followee_id => id ).limit(1).blank? ? false : true
  end

protected
  def choose_avatar
    if avatar_choice == "current"
      self.avatar = self.avatar_cache
    elsif avatar_choice == "upload"
      # No-op, avatar should be replaced if file was provided
    elsif avatar_choice == "gravatar"
      # Gravatar is the default, so remove any current avatar
      self.remove_avatar = true
    elsif %w(twitter facebook google).include? avatar_choice and send("#{avatar_choice}_avatar")
      self.remote_avatar_url = send("#{avatar_choice}_avatar")
    end
  end
  def fix_counter_cache
    University.decrement_counter(:users_count, self.university_group_id_was)
    University.increment_counter(:users_count, self.university_group_id)
  end
  private

  def set_username
    uname = user_name = self.full_name.gsub(" ","").downcase
    u_count = 0
    while User.where(username: uname).exists?
      u_count += 1
      uname = user_name + u_count.to_s
    end
    self.username = uname
  end

  def remove_groups
    self.groups.each do |g|
      g.destroy! if g.owner?(self)
    end
    self.group_memberships.destroy_all
  end

  def remove_follows
    follows = Follow.where("(follower_id = ? AND follower_type = ?) OR (followable_id = ? AND followable_type = ?)", self.id, "User", self.id, "User")
    follows.destroy_all unless follows.blank?
  end

  def check_dimensions
    if !avatar_cache.nil? && (avatar.width < 50 || avatar.height < 50)
      errors.add :avatar, "Dimension too small."
    end
  end
end
