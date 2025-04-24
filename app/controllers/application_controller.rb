# frozen_string_literal: true

# Used to manage some of the admin functionality of the application,
# Mostly used to manage the users and their sessions
class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :set_cache_buster
  helper_method :current_user

  # This will wipe the entire db of its users and their data leaving only the classes and blacklist
  def wipe_users
    User.delete_all

    master_emails = (ENV['ADMIN_EMAILS'] || "").split(",").map(&:strip)
    Admin.where.not(email: master_emails).delete_all

    GraderMatch.delete_all
    SeniorGraderMatch.delete_all
    TaMatch.delete_all
    WithdrawalRequest.delete_all
    Applicant.delete_all
    UnassignedApplicant.delete_all
    Recommendation.delete_all
    Dir[Rails.root.join("app/Charizard/util/public/output/*.csv")].each do |file|
      File.delete(file)
    File.delete(Rails.root.join("tmp", "TA_Matches.csv")) if File.exist?(Rails.root.join("tmp", "TA_Matches.csv"))
    File.delete(Rails.root.join("tmp", "Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Grader_Matches.csv"))
    File.delete(Rails.root.join("tmp", "Senior_Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Senior_Grader_Matches.csv"))
    end
    reset_session
    redirect_to root_path, notice: "All users have been cleared."
  end

  private

  def set_cache_buster
    response.headers["Cache-Control"] ="no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def require_login
    unless session[:user_id]
      redirect_to root_path, alert: "You must be logged in to access"
    end
  end
end
