class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment
  include Rakismet::Model

  enum status: [:pending, :approved, :spam, :trash, :reported, :displayed, :removed]

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :parent, class_name: 'Comment'
  belongs_to :user

  belongs_to :group, optional: true

  has_many :references, dependent: :destroy, as: :referenceable
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  acts_as_votable cacheable_strategy: :update_columns

  delegate :full_name, :email, :website, to: :user, prefix: true, allow_nil: true

  rakismet_attrs content: :comment, user_ip: :ip_address, author: proc { user.full_name }, author_email: proc { user.email }, author_url: proc { user.website }

  accepts_nested_attributes_for :references, reject_if: lambda { |r| r[:url].blank? }, allow_destroy: true

  validates :user, :commentable, :comment, presence: true

  after_create :update_status
  after_create :create_notifications
  after_create :create_activity

  def self.for user
    where(status: "approved", user_id: user.id)
  end

  def self.by user
    where user_id: user
  end

  protected

  def update_status
    self.status = :approved if user
    self.status ||= :spam if spam?
    self.status ||= :pending
    save
  end

  def create_notifications
    html_doc = Nokogiri::HTML self.comment
    spans = html_doc.search("span.atwho-inserted")
    mentions = spans.blank? ? [] : spans.text.split("@").select{|u| !u.blank? }
    # mentions = self.comment.scan(/@([a-z0-9_]+)/i).flatten.uniq
    unless mentions.empty?
      users = User.where(username: mentions)
      users.each do |u|
        u.notifications.create! title: I18n.t("notification.comment.mention_title", sender: user, commentable: commentable_type), body: comment, links: [{title: commentable_type == "Conversation" ? "" : commentable.title, href: [:ediofy, commentable] }], sender_id: user.id, notification_type: "Mention" if !u.notification_setting.blank? && u.notification_setting.notify_tags
        NotificationMailer.tag(self.user, u, commentable).deliver_later if !commentable.user.notification_setting.blank? && commentable.user.notification_setting.email_tags
      end
    end

    # if parent.blank?
    if self.user_id != commentable.user_id
      unless replied_to.blank?
        u = (Comment.find replied_to).user
        u.notifications.create! notifiable: commentable, title: I18n.t("notification.comment.reply.title_html", sender: user, commentable: commentable_type), body: comment, links: [{title: commentable_type == "Conversation" ? "" : commentable.title, href: [:ediofy, commentable] }], sender_id: user.id, notification_type: "Comment" if !u.notification_setting.blank? && u.notification_setting.notify_comments
      end
      commentable.user.notifications.create! notifiable: commentable, title: I18n.t("notification.comment.title_html", sender: user, commentable: commentable_type), body: comment, links: [{title: commentable_type == "Conversation" ? "" : commentable.title, href: [:ediofy, commentable] }], sender_id: user.id, notification_type: "Comment" if !commentable.user.notification_setting.blank? && commentable.user.notification_setting.notify_comments
      NotificationMailer.comment(self.user, commentable.user, commentable).deliver_later if !commentable.user.notification_setting.blank? && commentable.user.notification_setting.email_comments
    elsif !replied_to.blank?
      reply_user = (Comment.find replied_to).user
      if reply_user.id != commentable.user_id
        (Comment.find replied_to).user.notifications.create! notifiable: commentable, title: I18n.t("notification.comment.reply.title_html", sender: user, commentable: commentable_type), body: comment, links: [{title: commentable_type == "Conversation" ? "" : commentable.title, href: [:ediofy, commentable] }], sender_id: user.id, notification_type: "Comment" if !commentable.user.notification_setting.blank? && commentable.user.notification_setting.notify_comments
      end
    end
    # else
    #   parent.user.notifications.create! notifiable: commentable, title: I18n.t("notification.comment.reply.title_html", sender: user), body: comment, links: [{title: commentable_type == "Conversation" ? "" : commentable.title, href: [:ediofy, commentable] }], sender_id: user.id, notification_type: "Comment"
    # end
  end

  def create_activity
    user&.activity! 'comment.new', commentable: commentable, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'comment.new')&.cpd_time
  end
end
