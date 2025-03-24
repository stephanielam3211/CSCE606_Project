# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_google(auth)

    if user
      session[:user_id] = user.id
      session[:user] = { name: user.name, email: user.email }
      redirect_to root_path
    else
      flash[:alert] = "You must use a @tamu.edu email address to log in."
      redirect_to root_path, status: :see_other
    end
  end

  def destroy
    reset_session
    redirect_to root_path, status: :see_other
  end
end