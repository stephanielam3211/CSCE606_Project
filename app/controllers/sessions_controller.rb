# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = User.from_google(auth)
<<<<<<< HEAD
    session[:user_id] = user.id
    session[:email] = user.email
    session[:user] = user.name
    session[:role] = 'admin'
    redirect_to root_path
  rescue => e
    redirect_to root_path, alert: e.message
=======

    if user
      session[:user_id] = user.id
      session[:user] = { name: user.name, email: user.email }
      redirect_to root_path
    else
      flash[:alert] = "You must use a @tamu.edu email address to log in."
      redirect_to root_path, status: :see_other
    end
>>>>>>> 6494ce5be4711fb4bf086f97468f30688d2d4aa7
  end

  def destroy
    reset_session
<<<<<<< HEAD
    redirect_to root_path
=======
    redirect_to root_path, status: :see_other
>>>>>>> 6494ce5be4711fb4bf086f97468f30688d2d4aa7
  end
end