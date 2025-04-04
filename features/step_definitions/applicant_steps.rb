# frozen_string_literal: true

Given("the following applicant records exist:") do |table|
  table.hashes.each do |applicant_data|
    # Set a dummy course choice to satisfy validation.
    applicant_data['choice_1'] = 'CSCE 606'
    Applicant.create!(applicant_data)
  end
end

Given("I am logged in as a TAMU user") do
  visit root_path
  if page.has_link?("Login")
    click_link "Login"
  else
    puts "Login link not found; possibly already logged in."
  end
  expect(page).to have_content("You are logged in")
end

When("I navigate to the applicant search page") do
  visit applicants_path
end

When('I enter {string} into the {string} field') do |value, field_label|
  if field_label == "Search for Applicant"
    find("input.search-input", visible: true).set(value)
  else
    fill_in field_label, with: value
  end
end

When("I click the {string} button") do |button_name|
  click_button button_name
end

Then("I should see the applicant {string}") do |applicant_name|
  expect(page).to have_content(applicant_name)
end

Then("I should not see the applicant {string}") do |applicant_name|
  expect(page).not_to have_content(applicant_name)
end
