Given("the following applicant records exist:") do |table|
    table.hashes.each do |row|
      Applicant.create!(row)
    end
  end
  
  When("I navigate to the applicant search page") do
    visit applicants_path  # Adjust this path as needed for your app
  end
  
  When("I enter {string} into the {string} field") do |value, field_name|
    fill_in field_name, with: value
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
  