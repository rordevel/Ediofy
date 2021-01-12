class NotificationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM_EMAIL']

  def follow sender, reciever
    @sender = sender
    @reciever = reciever

    mail to: reciever.email, subject: "#{@sender.full_name} followed you on EDIOFY"
  end

  def comment sender, reciever, post
    @sender = sender
    @reciever = reciever
    @post = post
    
    mail to: reciever.email, subject: "#{@sender.full_name} commented on your post"
  end

  def like sender, reciever, post
    @sender = sender
    @reciever = reciever
    @post = post

    mail to: reciever.email, subject: "#{@sender.full_name} liked your post"
  end

  def tag sender, reciever, post
    @sender = sender
    @reciever = reciever
    @post = post

    mail to: reciever.email, subject: "tagged in the comment"
  end

  def media_processed reciever, media_id
    @reciever = reciever
    @media_id = media_id
    mail to: reciever.email, subject: "Your video upload is complete"
  end

  def content_reported(admin_emails, reported_by, content)
    @content = content
    @reported_by = reported_by
    mail to: admin_emails, subject: "Content Reported"
  end

  def group_invite(group, inviter, invitee, invite, notification)
    @group = group
    @inviter = inviter
    @invitee = invitee
    @invite = invite
    @notification = notification
    mail to: invitee.email, subject: "#{inviter.full_name} invites you to join group #{group.title}"
  end

  def group_join_request(group, sender, group_admin, invite_id, notification)
    @group = group
    @sender = sender
    @group_admin = group_admin
    @invite_id = invite_id
    @notification = notification
    mail to: group_admin.email, subject: "#{sender.full_name} requests to join your group #{group.title}"
  end
end
