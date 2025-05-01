# frozen_string_literal: true

# This controller manages the admin functions of the application

require "csv"
require "fileutils"

class WithdrawalRequestsController < ApplicationController
  before_action :authorize_admin!
  # This method is used to assign a role based on is the user has been assigned a role
  def new
    @withdrawal_request = WithdrawalRequest.new
    @applicant = Applicant.find_by(email: session[:email])

    if (ta_matches = TaMatch.find_by(stu_email: session[:email], assigned: true))
      @role = ta_matches
      @class = "ta_matches"
    elsif (senior_grader_matches = SeniorGraderMatch.find_by(stu_email: session[:email], assigned: true))
      @role = senior_grader_matches
      @class = "senior_grader_matches"
    elsif (grader_matches = GraderMatch.find_by(stu_email: session[:email], assigned: true))
      @role = grader_matches
      @class = "grader_matches"
    else
      @role = "Not Found"
    end
  end

  # This clears all the withdrawal requests from the database
  def clear
    WithdrawalRequest.delete_all
    redirect_to root_path, notice: "All Withdrawal Requests have been cleared."
  end

  # This is used to confirm the applicants assignment
  def confirm_assignment
    model = params[:file].classify.constantize
    record = model.find(params[:id])
    record.update(confirm: true)
    redirect_to new_withdrawal_request_path
  end

  # def show
  #  @applicant = Applicant.find_by(email: session[:email])

  #  if (ta_matches = TaMatch.find_by(stu_email: session[:email]))
  #    @role = ta_matches
  #    @class = "ta_matches"
  #  elsif (senior_grader_matches = SeniorGraderMatch.find_by(stu_email: session[:email]))
  #    @role = senior_grader_matches
  #    @class = "senior_grader_matches"
  #  elsif (grader_matches = GraderMatch.find_by(stu_email: session[:email]))
  #    @role = grader_matches
  #    @class = "grader_matches"
  #  else
  #    @role = "Not Found"
  #  end
  # end

  def confirm_app
  end


  def index
    @withdrawal_requests = WithdrawalRequest.all
  end

  private
  def authorize_admin!
    case session[:role].to_s
    when "admin"
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  def withdrawal_request_params
    params.require(:withdrawal_request).permit(:course_number, :section_id, :instructor_name, :instructor_email, :student_name, :student_email)
  end
end
