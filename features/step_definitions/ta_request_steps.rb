# frozen_string_literal: true

Given("I am logged in") do
  visit root_path
  # Click the login link if visible (adjust text as needed)
  if page.has_link?("Login")
    click_link "Login"
  end
  # Wait for a message indicating login succeeded
  expect(page).to have_content("You are logged in")
end

Given("I am on the TA request form page") do
  visit new_applicant_path
end

Given(/^the course "([^"]*)" exists$/) do |course_name|
  Course.find_or_create_by!(
    course_name: course_name,
    course_number: "606",
    section: "501",
    instructor: "Dr. Example",
    faculty_email: "example@tamu.edu"
  )
end

When("I fill in the TA form field {string} with {string}") do |field, value|
  if field == "applicant[positions]"
    # For the Select2 multiple select, set the value via JS.
    # Note: The underlying select has the class "positions-select"
    page.execute_script("$('select.positions-select').val(['#{value}']).trigger('change');")
  elsif field.include?("choice_")
    # For course choice fields, we'll use direct field setting since options may be dynamically loaded
    field_id = field.gsub(/[\[\]]/, '_').gsub('applicant_', '')
    begin
      select(value, from: field)
    rescue Capybara::ElementNotFound
      # If option doesn't exist in select, try setting the value directly
      find("##{field_id}", visible: true).set(value)
    end
  else
    element = find_field(field, visible: true)
    if element.tag_name == "select"
      select(value, from: field)
    else
      fill_in field, with: value
    end
  end
end

When(/^I fill in the hidden TA form field "([^"]*)" with "([^"]*)"$/) do |field_id, value|
  # Use find with visible: false instead of JavaScript, which works with any driver
  find("##{field_id}", visible: false).set(value)
end

When("I leave the {string} field blank") do |field|
  fill_in field, with: ""
end

When(/^I press the TA form button "([^"]*)"$/) do |button|
  click_button button
end

Then(/^I should see the success message "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |value, field|
  select value, from: field
end
