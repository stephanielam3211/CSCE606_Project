# frozen_string_literal: true

class SessionsController < ApplicationController
  protect_from_forgery except: :create
  skip_before_action :verify_authenticity_token,:require_login, only: [:create]
  
  def create
    auth = request.env['omniauth.auth']
    user = User.from_google(auth)

    if user.nil?
      redirect_to root_path, alert: "Unauthorized login attempt."
      return
    end
    
    session[:user_id] = user.id
    session[:email] = user.email
    session[:user] = user.name
    session[:role] = user.role
    redirect_to root_path
  rescue => e
    redirect_to root_path, alert: e.message
  end
  

  def destroy
    reset_session
    redirect_to root_path
  end
end
