class Ediofy::Users::UnauthController < EdiofyController

  def linkedin
    current_user.linkedin_uid = nil
    current_user.linkedin_auth = nil
    current_user.save! validate: false
    redirect_back fallback_location: ediofy_root_url, notice: t('ediofy.users.unauth.authentication_removed', provider: t('ediofy.users.omniauth_callbacks.providers.linkedin'))
  end

  def twitter
    current_user.twitter_uid = nil
    current_user.twitter_auth = nil
    current_user.save! validate: false
    redirect_back fallback_location: ediofy_root_url, notice: t('ediofy.users.unauth.authentication_removed', provider: t('ediofy.users.omniauth_callbacks.providers.twitter'))
  end

  def facebook
    current_user.facebook_uid = nil
    current_user.facebook_auth = nil
    current_user.save! validate: false
    redirect_back fallback_location: ediofy_root_url, notice: t('ediofy.users.unauth.authentication_removed', provider: t('ediofy.users.omniauth_callbacks.providers.facebook'))
  end

  def google
    current_user.google_uid = nil
    current_user.google_auth = nil
    current_user.save! validate: false
    redirect_back fallback_location: ediofy_root_url, notice: t('ediofy.users.unauth.authentication_removed', provider: t('ediofy.users.omniauth_callbacks.providers.google'))
  end
end
