When('I visit the login page') do
  visit '/login'
end

When('I fill in the login field {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press the login button {string}') do |button|
  click_button button
end

Then('I should see the login message {string}') do |text|
  expect(page).to have_content(text)
end

Given('I am logged in as {string}') do |username|
  visit '/login'
  fill_in 'username', with: username
  fill_in 'password', with: 'admin'
  click_button 'Login'
  expect(page).to have_content("Hello, #{username}! You are logged in.")
end

When('I click the login link {string}') do |link|
  if link.downcase == "logout"
    visit '/logout'
  else
    click_link link
  end
end

