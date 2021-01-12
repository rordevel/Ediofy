module Ediofy::User::FollowsHelper

  def manage_follow_link(user)
    out = []

    if user_signed_in?

    
      pending = FollowRequest.where(:follower_id => current_user, :followee_id => user.id ).limit(1).exists?.to_s

      if current_user.following?(user)
        # out.push(link_to t('ediofy.user.profile.unfollow'), ediofy_follow_path(id: user.id), remote: true, method: :delete, class: "unfollow-btn-#{user.id} follow-btn", data: { confirm: t('ediofy.user.profile.confirm_unfollow') } )
        out.push(link_to t('ediofy.user.profile.unfollow'), "#", onclick: "confirm_unfollow_user(this)", "data-id": user.id, id: "unfollow_user",  "data-pending": pending, class: "unfollow-btn-#{user.id} follow-btn" )
      else
        out.push(link_to t('ediofy.user.profile.follow'), ediofy_follows_path(user_id: user), remote: true, method: :post, class: "follow-btn-#{user.id} follow-btn")
      end

      out.join(' ').html_safe
    end
  end

end