# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Applicant Search", type: :feature do
  # Create test applicants with all required fields
  let!(:applicant1) {
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
  let!(:applicant2) {
    Applicant.create!(
      name: "Abhijit Rathore",
      email: "abhijitrathore1@tamu.edu",
      uin: "130",
      degree: "Master's",
      positions: "Manager",
      number: "2",
      hours: "35",
      citizenship: "US",
      cert: "Certified"
    )
  }
  let!(:applicant3) {
    Applicant.create!(
      name: "John Doe",
      email: "johndoe@tamu.edu",
      uin: "999",
      degree: "PhD",
      positions: "Researcher",
      number: "3",
      hours: "30",
      citizenship: "US",
      cert: "Certified"
    )
  }

  scenario "User searches by Name" do
    visit applicants_path
    fill_in "Enter Name, Email, or UIN", with: "Ayush"
    click_button "Search"

    expect(page).to have_content("Ayush Gautam")
    expect(page).not_to have_content("Abhijit Rathore")
    expect(page).not_to have_content("John Doe")
  end

  scenario "User searches by Email" do
    visit applicants_path
    fill_in "Enter Name, Email, or UIN", with: "abhijitrathore1@tamu.edu"
    click_button "Search"

    expect(page).to have_content("Abhijit Rathore")
    expect(page).not_to have_content("Ayush Gautam")
    expect(page).not_to have_content("John Doe")
  end
end
