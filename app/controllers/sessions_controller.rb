# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_google(auth)
    session[:user_id] = user.id
    session[:email] = user.email
    session[:user] = user.name
    session[:role] = 'admin'
    redirect_to root_path
  rescue => e
    redirect_to root_path, alert: e.message
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
