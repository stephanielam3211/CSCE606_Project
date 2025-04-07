class AdminsController < ApplicationController
    before_action :require_admin
  
    def new
    end
  
    def create
      email = params[:email]&.strip&.downcase
  
      if Admin.exists?(email: email)
        flash[:alert] = "#{email} is already an admin."
      else
        Admin.create!(email: email)
        flash[:notice] = "#{email} has been added as an admin!"
      end
  
      redirect_to new_admin_path
    end
  
    private
  
    def require_admin
      unless session[:role] == "admin"
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
  