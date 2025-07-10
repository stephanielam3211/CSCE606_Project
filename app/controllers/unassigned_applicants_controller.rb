# frozen_string_literal: true

# This controller handles the search functionality for unassigned applicants.
# used in the edit form in the assignment process
class UnassignedApplicantsController < ApplicationController
  before_action :authorize_admin!
  # searches by name
  def search
    term = params[:term].to_s.strip

    applicants = if term.present?
      UnassignedApplicant.where("name LIKE ?", "%#{term}%").limit(25)
    else
      UnassignedApplicant.all
    end
    render json: applicants.map do |applicant|
      {
        id: applicant.id,
        text: "#{applicant.stu_name} (#{applicant.email})",
        name: applicant.stu_name,
        email: applicant.email,
        degree: applicant.degree,
        uin: applicant.uin,
        number: applicant.number,
        citizenship: applicant.citizenship,
        hours: applicant.hours,
        prev_ta: applicant.prev_ta,
        cert: applicant.cert
      }
    end
  end
  # searches by email
  def search_email
    applicants = UnassignedApplicant.where("email LIKE ?", "%#{params[:term]}%").limit(10)
    render json: applicants.map { |applicant| {
      id: applicant.id,
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email,
      degree: applicant.degree,
      uin: applicant.uin,
      number: applicant.number,
      citizenship: applicant.citizenship,
      hours: applicant.hours,
      prev_ta: applicant.prev_ta,
      cert: applicant.cert } }
  end
  # searches by UIN
  def search_uin
    applicants = UnassignedApplicant.where("uin LIKE ?", "%#{params[:term]}%").limit(10)
    render json: applicants.map { |applicant| {
      id: applicant.id,
      text: "#{applicant.name} (#{applicant.email})",
      name: applicant.name,
      email: applicant.email,
      degree: applicant.degree,
      uin: applicant.uin,
      number: applicant.number,
      citizenship: applicant.citizenship,
      hours: applicant.hours,
      prev_ta: applicant.prev_ta,
      cert: applicant.cert } }
  end
  private
  def authorize_admin!
    case session[:role].to_s
    when "admin"
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end
end
