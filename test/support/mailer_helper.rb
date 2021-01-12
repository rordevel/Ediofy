module MailerHelper
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def extract_confirmation_url_from(email)
    email && email.body && email.body.match(/href="(.*(?:confirmation_token)[^"]+)/x)[1]
  end
end
