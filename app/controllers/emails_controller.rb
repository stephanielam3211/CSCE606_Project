# frozen_string_literal: true

# Used to send out emails from the App
class EmailsController < ApplicationController
  before_action :authenticate_user!

  def new 
  end

  # to send emails
  def create
    recipient_email = params[:email]
    subject = params[:subject]
    message = params[:message]
    sender_email = ENV["SMTP_EMAIL"]

    Rails.logger.info "Attempting to send email from #{sender_email} to #{recipient_email} with subject '#{subject}'"

    if sender_email.nil?
      redirect_to root_path, alert: "You must be logged in!"
      return
    end

    begin
      ApplicationMailer.send_custom_email(sender_email, recipient_email, subject, message).deliver_now
      Rails.logger.info "Email sent successfully!"
      redirect_to root_path, notice: "Email sent successfully!"
    rescue => e
      Rails.logger.error "Failed to send email: #{e.message}"
      redirect_to root_path, alert: "Failed to send email."
    end
  end

  private

  def authenticate_user!
    redirect_to root_path, alert: "You must be logged in!" unless session[:user_id]
  end
end
