class BlacklistsController < ApplicationController
    def index
      @blacklisted_students = Blacklist.all
    end
  
    def create
      @blacklist = Blacklist.new(blacklist_params)
      if @blacklist.save
        redirect_to blacklists_path, notice: "Student added to blacklist."
      else
        redirect_to blacklists_path, alert: "Failed to add student."
      end
    end
  
    def destroy
      @blacklist = Blacklist.find(params[:id])
      @blacklist.destroy
      redirect_to blacklists_path, notice: "Student removed from blacklist."
    end
  
    private
  
    def blacklist_params
      params.require(:blacklist).permit(:student_name, :student_email)
    end
  end
  