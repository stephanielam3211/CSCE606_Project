# frozen_string_literal: true

require "csv"
require "fileutils"

class WithdrawalRequestsController < ApplicationController
  def new
    @withdrawal_request = WithdrawalRequest.new
    @applicant = Applicant.find_by(email: session[:email])

    if (ta_matches = TaMatch.find_by(stu_email: session[:email]))
      @role = ta_matches
      @class = "ta_matches"
    elsif (senior_grader_matches = SeniorGraderMatch.find_by(stu_email: session[:email]))
      @role = senior_grader_matches
      @class = "senior_grader_matches"
    elsif (grader_matches = GraderMatch.find_by(stu_email: session[:email]))
      @role = grader_matches
      @class = "grader_matches"
    else
      @role = "Not Found"
    end
  end

  def create
    puts "DEBUG: create action triggered!"
    @withdrawal_request = WithdrawalRequest.new(withdrawal_request_params)

    if @withdrawal_request.save
      puts "DEBUG: Request saved successfully!"

      append_matching_entries(@withdrawal_request)

      flash[:notice] = "Withdrawal request submitted successfully."
      redirect_to root_path
    else
      puts "ERROR: Request did NOT save!"
      flash[:alert] = "There was an error submitting your request."
      render :new
    end
  end

  def show
    @applicant = Applicant.find_by(email: session[:email])

    if (ta_matches = TaMatch.find_by(stu_email: session[:email]))
      @role = ta_matches
      @class = "ta_matches"
    elsif (senior_grader_matches = SeniorGraderMatch.find_by(stu_email: session[:email]))
      @role = senior_grader_matches
      @class = "senior_grader_matches"
    elsif (grader_matches = GraderMatch.find_by(stu_email: session[:email]))
      @role = grader_matches
      @class = "grader_matches"
    else
      @role = "Not Found"
    end
  end

  def confirm_app
    

  end


  def index
    @withdrawal_requests = WithdrawalRequest.all
  end

  private

  def withdrawal_request_params
    params.require(:withdrawal_request).permit(:course_number, :section_id, :instructor_name, :instructor_email, :student_name, :student_email)
  end

  def append_matching_entries(request)
    stored_csv_path = Rails.root.join("app", "Charizard", "sample_input", "TA_Needs.csv")
    output_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "New_Needs.csv")

    output_dir = File.dirname(output_csv_path)
    FileUtils.mkdir_p(output_dir) unless File.directory?(output_dir)

    puts "DEBUG: Checking if stored CSV exists: #{stored_csv_path}"
    unless File.exist?(stored_csv_path)
      puts "ERROR: Stored CSV file NOT found at #{stored_csv_path}"
      return
    end
    puts "SUCCESS: Stored CSV file found!"

    matching_entries = []
    CSV.foreach(stored_csv_path, headers: true) do |row|
      if row["Course_Number"] == request.course_number &&
         row["Section"] == request.section_id &&
         row["Instructor"] == request.instructor_name &&
         row["Faculty_Email"] == request.instructor_email

        matching_entries << {
          "Course_Name" => row["Course_Name"],
          "Course_Number" => row["Course_Number"],
          "Section" => row["Section"],
          "Instructor" => row["Instructor"],
          "Faculty_Email" => row["Faculty_Email"],
          "TA" => row["TA"],
          "Senior_Grader" => row["Senior_Grader"],
          "Grader" => row["Grader"],
          "Professor Pre-Reqs" => row["Professor Pre-Reqs"]
        }
      end
    end

    if matching_entries.any?
      headers = [
        "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email",
        "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs"
      ]

      puts "DEBUG: Writing #{matching_entries.size} matching entries to #{output_csv_path}"
      file_exists = File.exist?(output_csv_path)

      CSV.open(output_csv_path, "a") do |csv|
        csv << headers unless file_exists # Ensure headers are written if the file is new
        matching_entries.each { |entry| csv << headers.map { |h| entry[h] } }
      end
      puts "SUCCESS: New_Needs.csv updated!"
    else
      puts "WARNING: No matching entries found in #{stored_csv_path}"
    end
  end
end
