# frozen_string_literal: true

# This controller handles the search functionality for unassigned applicants.
# used in the edit form in the assignment process
class UnassignedApplicantsController < ApplicationController
  # searches by name
  def search
    applicants = UnassignedApplicant.where("name LIKE ?", "%#{params[:term]}%").limit(10)
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
end
