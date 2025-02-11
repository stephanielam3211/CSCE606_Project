# frozen_string_literal: true

require "application_system_test_case"

class ApplicantsTest < ApplicationSystemTestCase
  setup do
    @applicant = applicants(:one)
  end

  test "visiting the index" do
    visit applicants_url
    assert_selector "h1", text: "Applicants"
  end

  test "should create applicant" do
    visit applicants_url
    click_on "New applicant"

    fill_in "Advisor", with: @applicant.advisor
    fill_in "Cert", with: @applicant.cert
    fill_in "Choice 1", with: @applicant.choice_1
    fill_in "Choice 10", with: @applicant.choice_10
    fill_in "Choice 2", with: @applicant.choice_2
    fill_in "Choice 3", with: @applicant.choice_3
    fill_in "Choice 4", with: @applicant.choice_4
    fill_in "Choice 5", with: @applicant.choice_5
    fill_in "Choice 6", with: @applicant.choice_6
    fill_in "Choice 7", with: @applicant.choice_7
    fill_in "Choice 8", with: @applicant.choice_8
    fill_in "Choice 9", with: @applicant.choice_9
    fill_in "Citizenship", with: @applicant.citizenship
    fill_in "Degree", with: @applicant.degree
    fill_in "Email", with: @applicant.email
    fill_in "Hours", with: @applicant.hours
    fill_in "Name", with: @applicant.name
    fill_in "Number", with: @applicant.number
    fill_in "Positions", with: @applicant.positions
    fill_in "Prev course", with: @applicant.prev_course
    fill_in "Prev ta", with: @applicant.prev_ta
    fill_in "Prev uni", with: @applicant.prev_uni
    fill_in "Uin", with: @applicant.uin
    click_on "Create Applicant"

    assert_text "Applicant was successfully created"
    click_on "Back"
  end

  test "should update Applicant" do
    visit applicant_url(@applicant)
    click_on "Edit this applicant", match: :first

    fill_in "Advisor", with: @applicant.advisor
    fill_in "Cert", with: @applicant.cert
    fill_in "Choice 1", with: @applicant.choice_1
    fill_in "Choice 10", with: @applicant.choice_10
    fill_in "Choice 2", with: @applicant.choice_2
    fill_in "Choice 3", with: @applicant.choice_3
    fill_in "Choice 4", with: @applicant.choice_4
    fill_in "Choice 5", with: @applicant.choice_5
    fill_in "Choice 6", with: @applicant.choice_6
    fill_in "Choice 7", with: @applicant.choice_7
    fill_in "Choice 8", with: @applicant.choice_8
    fill_in "Choice 9", with: @applicant.choice_9
    fill_in "Citizenship", with: @applicant.citizenship
    fill_in "Degree", with: @applicant.degree
    fill_in "Email", with: @applicant.email
    fill_in "Hours", with: @applicant.hours
    fill_in "Name", with: @applicant.name
    fill_in "Number", with: @applicant.number
    fill_in "Positions", with: @applicant.positions
    fill_in "Prev course", with: @applicant.prev_course
    fill_in "Prev ta", with: @applicant.prev_ta
    fill_in "Prev uni", with: @applicant.prev_uni
    fill_in "Uin", with: @applicant.uin
    click_on "Update Applicant"

    assert_text "Applicant was successfully updated"
    click_on "Back"
  end

  test "should destroy Applicant" do
    visit applicant_url(@applicant)
    click_on "Destroy this applicant", match: :first

    assert_text "Applicant was successfully destroyed"
  end
end
