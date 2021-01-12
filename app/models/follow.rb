class Follow < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  # include Rails.application.routes.url_helpers

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" and "follower" interface
  belongs_to :followable, polymorphic: true
  belongs_to :follower,   polymorphic: true

  
  after_create :send_follow_notification, if: lambda{ |f| !f.followable.notification_setting.blank? && f.followable.notification_setting.notify_follows && f.follower.following?(f.followable) }
  
  
  after_create :send_follow_email, if: lambda{ |f| !f.followable.notification_setting.blank? && f.followable.notification_setting.email_follows && f.follower.following?(f.followable) }
  # after_destroy :send_unfollow_notification, if: lambda{ |f| !f.followable.notification_setting.blank? && f.followable.notification_setting.notify_follows }

  def block!
    self.update_attribute(:blocked, true)
  end

  private

  def send_follow_notification
    url_options = ActionMailer::Base.default_url_options
    followable.notifications.create sender: follower, title: I18n.t('notification.follows.follow.title'), notification_type: "Follow", body:  I18n.t('notification.follows.follow.body_html', follower: "follower", follower_url: Rails.application.routes.url_helpers.ediofy_user_path(follower, url_options)), image_url: follower.avatar.x_small.url, links: []
  end

  def send_follow_email
    NotificationMailer.follow(follower, followable).deliver_later
  end
end
