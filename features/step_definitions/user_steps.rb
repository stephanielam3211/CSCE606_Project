# frozen_string_literal: true

When('I log in with Google') do
  visit '/auth/google_oauth2'
end

Given('I am logged in with Google') do
  step 'I log in with Google'
  expect(page).to have_content('Hello, Admin User! You are logged in.')
end

When('I click the logout link') do
  visit logout_path(method: :delete)
end

Then(/^I should see the login message "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end
