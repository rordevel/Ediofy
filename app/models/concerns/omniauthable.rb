module Omniauthable
  extend ActiveSupport::Concern
  PROVIDERS = [:facebook].freeze
  module ClassMethods
    def find_for_omniauth auth
      # first conditions: {"#{auth.provider}_uid" => auth.uid}
      self.find_by "#{auth.provider}_uid" => auth.uid
    end

    # For signing in via an omniauth strategy
    def find_or_create_for_omniauth auth, &block
      email = auth.info.email
      # This is just a placeholder for indexes and validations etc.
      # (twitter doesn't give us an email)
      email ||= "#{auth.info.nickname || auth.uid}@#{auth.provider}.auth"

      user = find_for_omniauth auth
      user ||= find_or_initialize_by email: email

      user.omniauth!(auth, &block) and user
    end
  end

  # A transient attribute for validations, callbacks etc. to respect
  # during an omniauth sign up.
  def omniauth?
    !!@omniauth
  end

  def unauth auth
    if self.send("#{auth.provider}?")
      self["#{auth.provider}_uid"] = nil
      self["#{auth.provider}_auth"] = nil
      self.save( validate: false )
    end
  end

  # Clones all auths except the provided from another omniauthable
  # Will not overwrite existing auths
  def omniauthclone omniauthable, auth=nil
    PROVIDERS.reject{|p| p == auth}.each do |provider|
      unless self.send("#{provider}?")
        if omniauthable.send("#{provider}?")
          self["#{auth.provider}_uid"] = omniauthable["#{auth.provider}_uid"]
          self["#{auth.provider}_auth"] = omniauthable["#{auth.provider}_auth"]
          self.save
        end
      end
    end
  end

  # Associate with omniauth auth strategy, potentially a new member
  def process_uri(uri)
    require 'open-uri'
    require 'open_uri_redirections'
    open(uri, :allow_redirections => :safe) do |r|
      r.base_uri.to_s
    end
  end
  def omniauth! auth
    @omniauth = true

    # Email is assumed to be already set

    # Set a password for new users to be valid
    set_random_password unless encrypted_password?

    # Twitter adds a spammy oauth access token containing http
    # responses and such which we get rid of for serialization.
    # We already have oauth credentials in auth.credentials.
    auth.extra.delete :access_token if auth.extra? and auth.extra.access_token?

    # Save the auth info for later
    self["#{auth.provider}_uid"] = auth.uid
    self["#{auth.provider}_auth"] = auth

    # Intuit some attributes from auth, if possible
    # (don't use ||=, some have defaults)
    self.full_name = auth.info.name || auth.info.nickname unless full_name?
    self.first_name = auth.info.first_name unless first_name?
    self.last_name = auth.info.last_name unless last_name?
    # Did we get an avatar to pinch, too?
    if auth.info.image? and not avatar?#social_account_avatar
      url = auth.info.image.dup

      # Twitter will serve a tiny version by default, but we can
      # reconstruct the original URL by removing the "_normal" suffix.
      url.sub!(/_normal(.*?)\Z/, '\1') if auth.provider == "twitter"

      # The facebook avatar has a type parameter which we can
      # change to get a bigger picture.
      url.sub!(/type=\w+(.*?)\Z/, 'type=large\1') if auth.provider == "facebook"

      url = process_uri(auth.info.image) if auth.provider == 'facebook'
      self.remote_avatar_url = url
    end
    Rails.logger.info("[Auth info]: #{auth.info}")
    # Add biographyfrom twitter if present
    self.biography = auth.extra.try(:raw_info).try(:description) || '' unless self.biography.present?

    # Add website from twitter if present
    self.website = auth.extra.try(:raw_info).try(:url) || '' unless self.website.present?
    # Add website from facebook if present (facebook allows multiple URLs inside the field seperated by \n)
    self.website = (auth.extra.try(:raw_info).try(:website) || '').split("\n").first unless self.website.present?

    # We might get a locale/language
    # There's a database default so we override it when this is a new record.
    if new_record?
      auth_locale =
        auth.extra.try(:raw_info).try(:locale).presence ||
        auth.extra.try(:raw_info).try(:lang).presence

      if auth_locale.present?
        # Might be a variant, e.g. "en_GB", so attempt the whole thing first...
        self.locale = auth_locale if User::AVAILABLE_LOCALES.include? auth_locale
        # .. then just the generalised locale, e.g. "en"
        self.locale = auth_locale[0...2] if User::AVAILABLE_LOCALES.include? auth_locale[0...2]
      end
    end

    # Allow overrides to be applied before save
    yield self if block_given?

    # This must save for #find_or_create_for_omniauth to work
    save!
  end

  def twitter?
    twitter_uid?
  end

  def facebook?
    facebook_uid?
  end

  def google?
    google_uid?
  end

  def linkedin?
    linkedin_uid?
  end

  def twitter_name
    twitter_auth.info.nickname if twitter?
  end

  def facebook_name
    facebook_auth.info.name if facebook?
  end

  def google_name
    google_auth.info.name if google?
  end

  def linkedin_name
    linkedin_auth.info.name if linkedin?
  end

  def twitter_url
    twitter_auth.info.urls['Twitter'] if twitter?
  end

  def facebook_url
    facebook_auth.info.urls['Facebook'] if facebook?
  end

  def google_url
    google_auth.extra.raw_info.link if google?
  end

  def linkedin_url
    linkedin_auth.info.urls.public_profile if linkedin?
  end

  def twitter
    @twitter ||= begin
      Twitter::Client.new oauth_token: twitter_auth.credentials.token, oauth_token_secret: twitter_auth.credentials.secret
    rescue Twitter::Error => e
      Rails.logger.info("[TWITTER CONNECTION] Failure for #{self.inspect}: #{e.to_s}")
      nil
    end if twitter?
  end

  def facebook
    @facebook ||= begin
      Koala::Facebook::API.new facebook_auth.credentials.token
    rescue Koala::KoalaError => e
      Rails.logger.info("[FACEBOOK CONNECTION] Failure for #{self.inspect} #{e.to_s}")
      nil
    end if facebook?
  end

  def google
    @google ||= begin
      Koala::Google::API.new google_auth.credentials.token
    rescue Koala::KoalaError => e
      Rails.logger.info("[GOOGLE CONNECTION] Failure for #{self.inspect} #{e.to_s}")
      nil
    end if google?
  end

  def linkedin
    @linkedin ||= begin
      LinkedIn::Client.new.tap do |client|
        client.authorize_from_access linkedin_auth.credentials.token, linkedin_auth.credentials.secret
      end
    end if linkedin?
  end
end
