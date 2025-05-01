# frozen_string_literal: true

# This manages the blacklists of students
class BlacklistsController < ApplicationController
  before_action :authorize_admin!
  def index
    @blacklisted_students = Blacklist.all
  end

  # Will create a new blacklist entry
  def create
    @blacklist = Blacklist.new(blacklist_params)
    if @blacklist.save
      redirect_to blacklists_path, notice: "Student added to blacklist."
    else
      redirect_to blacklists_path, alert: "Failed to add student."
    end
  end

  # This will delete a blacklist entry
  def destroy
    @blacklist = Blacklist.find(params[:id])
    @blacklist.destroy
    redirect_to blacklists_path, notice: "Student removed from blacklist."
  end

  private

  def authorize_admin!
    case session[:role].to_s
    when "admin"
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  def blacklist_params
    params.require(:blacklist).permit(:student_name, :student_email)
  end
end
