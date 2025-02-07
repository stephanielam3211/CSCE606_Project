require 'rails_helper'

RSpec.describe Applicant, type: :model do
  it "is valid with a name, email, degree, posistions, number, uin, hours, citizenship, and cert" do
    applicant = Applicant.new(name: "John Doe", email: "john@example.com", degree: "PhD", positions:"TA", number:"512-555-5555",
     uin:"123456789", hours:"13", citizenship:"USA", cert:"1")
    expect(applicant).to be_valid
  end

  it "is invalid without a name" do
    applicant = Applicant.new(email: "john@example.com", degree: "PhD")
    expect(applicant).not_to be_valid
  end
end
