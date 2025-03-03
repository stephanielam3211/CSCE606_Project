# frozen_string_literal: true

Given('the following courses exist:') do |table|
  Course.create!(course_name: "PROGRAMMING I", course_number: "CS101", section: "A", instructor: "Dr. Smith", faculty_email: "qwreqw@tamu.edu")
  Course.create!(course_name: "DATA STRUCTURES", course_number: "CS102", section: "B", instructor: "Prof. Johnson", faculty_email: "sdgsdg@tamu.edu")
end
  When("I visit the courses page") do
    visit courses_path
  end

  When("I fill in {string} with {string}") do |field, value|
    fill_in field, with: value
  end

  When("I press {string}") do |button|
    click_button button
  end

  Then("I should see {string}") do |text|
    expect(page).to have_content(text)
  end
