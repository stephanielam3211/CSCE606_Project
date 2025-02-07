class SessionsController < ApplicationController
  def new
  end

  def create
    username = params[:username]
    password = params[:password]

    #dummy login
    if username == "admin" && password == "admin"
      session[:user] = username
      redirect_to root_path, notice: "Logged in!"
    else
      flash.now[:alert] = "Invalid username or password."
      render :login
    end
  end

  def destroy
    session[:user] = nil
    redirect_to login_path, notice: "Logged out!"
  end
end