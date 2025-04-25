class AdvisorsController < ApplicationController
  require 'csv'
  before_action :require_admin

  def index
    @advisors = Advisor.all
  end

  def new
    @advisor = Advisor.new
    @advisors = Advisor.all
  end

  def show
  end

  def import_csv
    if params[:file].present?
      begin
        CSV.foreach(params[:file].path, headers: true) do |row|
          Advisor.create!(row.to_hash.slice("name", "email"))
        end
        redirect_to new_advisor_path, notice: "CSV imported successfully!"
      rescue => e
        redirect_to new_advisor_path, alert: "Import failed: #{e.message}"
      end
    else
      redirect_to new_advisor_path, alert: "Please upload a CSV file."
    end
  end


  def create
    @advisor = Advisor.new(advisor_params)
    if @advisor.save
      flash[:notice] = "Advisor added!"
      redirect_to new_advisor_path
    else
      flash[:alert] = "There was a problem."
      @advisors = Advisor.all
      render :new
    end
  end

  def clear(skip_redirect: false)
    Advisor.delete_all
    unless skip_redirect
      redirect_to root_path, notice: 'All Advisors has been cleared.'
      return
    end
  end

  def destroy
    @advisor = Advisor.find(params[:id])
    @advisor.destroy
    redirect_to new_advisor_path, notice: "Student removed from blacklist."
  end

  def require_admin
    unless session[:role] == "admin"
      redirect_to root_path, alert: "Access denied."
    end
  end 
  private

  def advisor_params
    params.require(:advisor).permit(:name, :email)
  end
end
