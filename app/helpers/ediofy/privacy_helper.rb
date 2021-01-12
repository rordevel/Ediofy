module Ediofy::PrivacyHelper

  def with_privacy(actor, lock_level, &block)
    if user_signed_in? && current_user.friends_with?(actor)
      ## Using friend level
      privacy_level = actor.setting.privacy_friends
    else
      ## Using public level
      privacy_level = actor.setting.privacy_public
    end
    if privacy_level < lock_level || current_user == actor
      if block
        capture(&block)
      else
        true
      end
    else
      if block
      else
        false
      end
    end
  end

  def do_with_privacy(actor, level, can, cannot)
    if with_privacy(actor,level)
      can
    else
      cannot
    end
  end

end