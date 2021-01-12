class UserActivityObserver < ActiveRecord::Observer
  observe :user

  def after_save user
    if user.profile_complete?
      user.badge! ProfileCompletedBadge.instance
    end

    if user.twitter_uid_changed? and user.twitter_uid?
      user.activity! "users.auth.twitter", twitter: user.twitter_name
      user.badge! TwitterBadge.instance, twitter: user.twitter_name
    end

    if user.facebook_uid_changed? and user.facebook_uid?
      user.activity! "users.auth.facebook", facebook: user.facebook_name
      user.badge! FacebookBadge.instance, facebook: user.facebook_name
    end

    if user.google_uid_changed? and user.google_uid?
      user.activity! "users.auth.google", google: user.google_name
      user.badge! GoogleBadge.instance, google: user.google_name
    end

    if user.linkedin_uid_changed? and user.linkedin_uid?
      user.activity! "users.auth.linkedin", linkedin: user.linkedin_name
      user.badge! LinkedinBadge.instance, linkedin: user.linkedin_name
    end
  end

  def after_create user
    user.activity! "users.register", default_points: 50, default_time_spent: 60*15
    # XXX: To be removed later
    user.badge! EarlyAdopterBadge.instance
  end

  def after_update user
    if (user.changed & %w(first_name last_name email hospital university bio)).present?
      user.activity! "users.profile.update"
    end
  end
end
