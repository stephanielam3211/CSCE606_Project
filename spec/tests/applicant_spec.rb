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
      cert: "Certified",
      choice_1: "CSCE 606"
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
      expect(applicant.name).to eq("Ayush Gautam")
    end
  end

  describe "DELETE #destroy" do
    let!(:applicant_to_delete) { Applicant.create!(
      name: "Ayush Ga",
      email: "ayushg@tamu.edu",
      uin: "121",
      degree: "Masters",
      positions: "Developer",
      number: "1",
      hours: "40",
      citizenship: "US",
      cert: "Certified",
      choice_1: "606"
    )}
    it "deletes the applicant" do
      expect(Applicant.exists?(applicant_to_delete.id)).to be true
      delete :destroy, params: { id: applicant_to_delete.id }
      expect {
        Applicant.find(applicant_to_delete.id).destroy
      }.to change(Applicant, :count).by(-1)
      expect(Applicant.exists?(applicant_to_delete.id)).to be false
    end
  end
end

RSpec.describe Applicant, type: :model do
  it "is valid with a name, email, degree, posistions, number, uin, hours, citizenship, and cert" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", positions: "TA", number: "512-555-5555",
     uin: "123456789", hours: "13", citizenship: "USA", cert: "1",
     choice_1: "606")
    expect(applicant).to be_valid
  end

  it "is invalid without a name" do
    applicant = Applicant.new(email: "john@example.com", degree: "PhD")
    expect(applicant).not_to be_valid
  end

  it "is invalid without an email" do
    applicant = Applicant.new(name: "John Doe", degree: "PhD", positions: "TA", number: "512-555-5555",
    uin: "123456789", hours: "13", citizenship: "USA", cert: "1",
    choice_1: "606")
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
