# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_login
  before_action :set_cache_buster
  helper_method :current_user

  def wipe_users
    User.delete_all
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
