# frozen_string_literal: true

Given('I am logged in') do
    visit login_path
    fill_in "username", with: "admin"
    fill_in "password", with: "admin"
    click_button "Login"
    expect(page).to have_content("Hello, admin!")
  end

  Given('I am on the home page') do
    visit root_path
    expect(page).to have_content("TA Assignment Home Page")
  end

  Given('I am on the TA request form page') do
    visit new_applicant_path
    expect(page).to have_current_path(new_applicant_path, ignore_query: true)
  end

  When('I fill in the TA form field {string} with {string}') do |field_name, value|
    fill_in field_name, with: value
  end

  When('I leave the {string} field blank') do |field_name|
    fill_in field_name, with: ""
  end

  When('I press {string}') do |button_text|
    expect(page).to have_button(button_text, wait: 5)
    click_button button_text
  end

  Then('I should see {string}') do |confirmation_message|
    expect(page).to have_content(confirmation_message)
  end

  Then('I should see the TA request confirmation {string}') do |confirmation_message|
    expect(page).to have_content("Applicant was successfully created.", wait: 5)
  end

  Then('I should see the TA request form errors') do
    expect(page).to have_content("errors prohibited this applicant from being saved")
    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Email can't be blank")
    expect(page).to have_content("Degree can't be blank")
    expect(page).to have_content("Positions can't be blank")
    expect(page).to have_content("Number can't be blank")
    expect(page).to have_content("Uin can't be blank")
    expect(page).to have_content("Hours can't be blank")
    expect(page).to have_content("Citizenship can't be blank")
    expect(page).to have_content("Cert can't be blank")
  end
