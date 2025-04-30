# frozen_string_literal: true

class AdvisorsController < ApplicationController
  require "csv"
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
      file = params[:file]
      # Check if the file is a CSV
      if file.content_type != "text/csv"
        session[:notice] = "Error importing file: Please Upload a CVS file"
        redirect_to new_advisor_path, notice: "Please upload a CSV file."
        return
      end
      begin
        csv_data = CSV.read(file.path, headers: true)
        csv_data.each do |row|
          # Normalize the headers
          row = row.to_h.transform_keys { |key| key.strip.downcase }.transform_values { |value| value.strip if value.respond_to?(:strip)}
          advisor_attrs = {
            name: row["name"],
            email: row["email"] || row["email address"]
          }

        Advisor.create!(advisor_attrs)
        end
        redirect_to new_advisor_path, notice: "CSV imported successfully!"
      rescue StandardError => e
        Rails.logger.error "Error importing CSV: #{e.message}"
        Rails.logger.error "Check Headers: #{csv_data.headers.inspect}"
        session[:notice] = "Error importing file: #{e.message}, Check headers for proper capitalization and whitespace"
        redirect_to new_advisor_path, notice: "Import failed: #{e.message}"
      end
    else
      session[:notice] = "Error importing file: Please Upload a CVS file"
      redirect_to new_advisor_path, notice: "Please upload a CSV file."
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
      redirect_to root_path, notice: "All Advisors has been cleared."
      nil
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
