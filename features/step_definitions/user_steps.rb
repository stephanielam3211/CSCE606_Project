When('I visit the login page') do
    visit '/login'  # Matches the route from config/routes.rb
  end
  
  When('I fill in {string} with {string}') do |field, value|
    fill_in field, with: value
  end
  
  When('I press {string}') do |button|
    click_button button
  end
  
  Then('I should see {string}') do |text|
    expect(page).to have_content(text)
  end
  
  Given('I am logged in as {string}') do |username|
    visit '/login'
    fill_in 'username', with: username
    fill_in 'password', with: 'admin' # Assuming 'admin' is the correct password
    click_button 'Login'
    expect(page).to have_content("Hello, #{username}! You are logged in.")
  end
  
  When('I click {string}') do |link|
    if link.downcase == "logout"
      visit '/logout'  # Force GET request since routes.rb defines logout as GET
    else
      click_link link
    end
  end
  