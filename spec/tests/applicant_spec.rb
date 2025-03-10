# frozen_string_literal: true

require 'rails_helper'


RSpec.describe ApplicantsController, type: :controller do
  let!(:applicant) {
    Applicant.create!(
      name: "Ayush Gautam",
      email: "ayushgautam@tamu.edu",
      uin: "121",
      degree: "Master's",
      positions: "Developer",
      number: "1",
      hours: "40",
      citizenship: "US",
      cert: "Certified"
    )
  }
  describe "PATCH #update" do
    let(:valid_attributes) do
      {
        name: "Ayush Gautamy"
      }
    end

    it "updates an applicant and redirects" do
      patch :update, params: { id: applicant.id, applicant: valid_attributes }
      applicant.reload
      expect(applicant.name).to eq("Ayush Gautamy")
      expect(response).to redirect_to(applicant)
      expect(flash[:notice]).to eq("Applicant was successfully updated.")
    end
  end

  describe "DELETE #destroy" do
  let!(:applicant) { Applicant.create!(
    name: "Ayush Gautam",
    email: "ayushggautam@tamu.edu",
    uin: "121",
    degree: "Master's",
    positions: "Developer",
    number: "1",
    hours: "40",
    citizenship: "US",
    cert: "Certified"
  )}
  it "deletes the course and redirects to index" do
    expect {
      delete :destroy, params: { id: applicant.id }
    }.to change(Applicant, :count).by(-1)

    expect(response).to redirect_to(applicants_path)
    expect(flash[:notice]).to eq("Applicant was successfully destroyed.")
  end
end
end

RSpec.describe Applicant, type: :model do
  it "is valid with a name, email, degree, posistions, number, uin, hours, citizenship, and cert" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", positions: "TA", number: "512-555-5555",
     uin: "123456789", hours: "13", citizenship: "USA", cert: "1")
    expect(applicant).to be_valid
  end

  it "is invalid without a name" do
    applicant = Applicant.new(email: "john@example.com", degree: "PhD")
    expect(applicant).not_to be_valid
  end

  it "is invalid without an email" do
    applicant = Applicant.new(name: "John Doe", degree: "PhD", positions: "TA", number: "512-555-5555",
    uin: "123456789", hours: "13", citizenship: "USA", cert: "1")
    expect(applicant).not_to be_valid
  end

  it "is invalid without a degree" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", positions: "TA", number: "512-555-5555",
    uin: "123456789", hours: "13", citizenship: "USA", cert: "1")
    expect(applicant).not_to be_valid
  end

  it "is invalid without an uin" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", positions: "TA", number: "512-555-5555",
    hours: "13", citizenship: "USA", cert: "1")
    expect(applicant).not_to be_valid
  end

  it "is invalid without a position" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", number: "512-555-5555",
     uin: "123456789", hours: "13", citizenship: "USA", cert: "1")
    expect(applicant).not_to be_valid
  end

  it "is invalid without a hours" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", positions: "TA", number: "512-555-5555",
     uin: "123456789", citizenship: "USA", cert: "1")
    expect(applicant).not_to be_valid
  end
end
