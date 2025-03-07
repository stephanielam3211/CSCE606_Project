# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Course Search", type: :feature do
    let!(:course) { Course.create!(course_name: "CSCE 606", course_number: "606", section: "500", instructor: "Dr.richey", faculty_email: "rrrr@tamu.edu") }

    scenario "User searches for a course" do
      visit courses_path
      expect(Course.count).to be > 0

      fill_in "Enter Course Name, Number, Section, or Instructor", with: "CSCE 606"
      click_button "Search"
      expect(page).to have_css("td", text: "CSCE 606")
    end

    scenario "User searches for a course number" do
      visit courses_path
      expect(Course.count).to be > 0

      fill_in "Enter Course Name, Number, Section, or Instructor", with: "606"
      click_button "Search"
      expect(page).to have_css("td", text: "606")
    end

    scenario "User searches for a section" do
      visit courses_path
      expect(Course.count).to be > 0

      fill_in "Enter Course Name, Number, Section, or Instructor", with: "500"
      click_button "Search"
      expect(page).to have_css("td", text: "500")
    end

    scenario "User searches for a Instructor" do
      visit courses_path
      expect(Course.count).to be > 0

      fill_in "Enter Course Name, Number, Section, or Instructor", with: "Dr.richey"
      click_button "Search"
      expect(page).to have_css("td", text: "Dr.richey")
    end
  end
