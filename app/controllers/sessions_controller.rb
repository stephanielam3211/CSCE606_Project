# frozen_string_literal: true

class SessionsController < ApplicationController
  protect_from_forgery except: :create
  skip_before_action :verify_authenticity_token, only: [:create]
  
  def create
    auth = request.env['omniauth.auth']
    user = User.from_google(auth)
    session[:user_id] = user.id
    session[:user] = user.name
    session[:role] = 'admin'
    redirect_to root_path, notice: "Signed in successfully!"
  rescue => e
    redirect_to root_path, alert: e.message
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out successfully!"
  end
end
