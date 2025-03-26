# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_EMAIL']
  layout 'mailer'

  def send_custom_email(sender_email, recipient_email, subject, message)
    @message = message
    mail(to: recipient_email, from: sender_email, subject: subject)
  end
end
