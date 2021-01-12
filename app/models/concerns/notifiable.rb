module Notifiable
  extend ActiveSupport::Concern
  included do
    include ActionDispatch::Routing::PolymorphicRoutes
    include Rails.application.routes.url_helpers
    after_create :notify_followers
    def notify_followers
      self.user.followers.each do |u|
        u.notifications.create(
          sender: self.user, 
          title: I18n.t("notification.#{self.class.name.downcase}.title"), 
          notification_type: self.class.name, 
          body:  I18n.t("notification.#{self.class.name.downcase}.body_html",
            content: self,
            content_url: polymorphic_path([:ediofy, self])),
          image_url: self.user.avatar.x_small.url, 
          links: []
        ) if !u.notification_setting.blank? && u.notification_setting.notify_followed_contributor_post
      end
    end
  end
end