class EdiofyMailer < ActionMailer::Base
  default from: ENV['DEFAULT_FROM_EMAIL']

  def invite user, address
    @user = user

    mail from: "#{user} <#{user.email}>",
      to: address.to_s,
      subject: "#{@user} would like to be your friend on EDIOFY"
  end

  def mail_digest user
    @user = user
    @badges = user.badge_users.this_week

    mail to: "#{user} <#{user.email}>",
      subject: 'EDIOFY Weekly Digest'
  end

  def welcome_mail user
    @user = user

    @profile_complete = user.profile_complete?
    @has_answers = user.ediofy_selected_answers.any?
    @has_questions = user.questions.any?
    @has_media = user.media.any?
    @friend_count = user.friends.count

    mail to: user.email,
      subject: 'Welcome to EDIOFY - The Global Medical Education Project'
  end
end
