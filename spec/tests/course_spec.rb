# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoursesController, type: :controller do
  describe "POST #create" do
    let(:valid_attributes) do
      {
        course_name: "CSCE 607",
        course_number: "606",
        section: "500",
        instructor: "Dr. Richey",
        faculty_email: "rrrr@tamu.edu"
      }
    end
    let(:invalid_attributes) do
      { course_name: "", course_number: "" }
    end

    it "creates a new course and redirects to courses index" do
      expect {
        post :create, params: { course: valid_attributes }
      }.to change(Course, :count).by(1)

      expect(response).to redirect_to(courses_path)
      expect(flash[:notice]).to eq("Course was successfully created.")
    end
  end
  describe "PATCH #update" do
  let!(:course) { Course.create!(course_name: "CSCE 607", course_number: "606", section: "500", instructor: "Dr. Richey", faculty_email: "rrrr@tamu.edu") }
    let(:valid_attributes) do
      {
        instructor: "Ayush Gautamy"
      }
    end

    it "updates a course" do
      patch :update, params: { id: course.id, course: valid_attributes }
      course.reload
      expect(course.instructor).to eq("Ayush Gautamy")
      expect(flash[:notice]).to eq("Course was successfully updated.")
    end
  end

  describe "DELETE #destroy" do
    let!(:course) { Course.create!(course_name: "CSCE 607", course_number: "606", section: "500", instructor: "Dr. Richey", faculty_email: "rrrr@tamu.edu") }
    it "deletes the course and redirects to index" do
      expect {
        delete :destroy, params: { id: course.id }
      }.to change(Course, :count).by(-1)

      expect(response).to redirect_to(courses_path)
      expect(flash[:notice]).to eq("Course was successfully deleted.")
    end
  end

  describe "DELETE #clear" do
    let!(:course1) { Course.create!(course_name: "CSCE 607", course_number: "606", section: "500", instructor: "Dr. Richey", faculty_email: "rrrr@tamu.edu") }
    let!(:course2) { Course.create!(course_name: "CSCE 607", course_number: "606", section: "500", instructor: "Dr.richey", faculty_email: "rrrcr@tamu.edu") }
    it "deletes the course and redirects to index" do
      expect {
        delete :clear
      }.to change(Course, :count).by(-2)

      expect(response).to redirect_to(courses_path)
      expect(flash[:notice]).to eq("All courses have been deleted.")
    end
  end
end

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

    scenario "user adds a course" do
      visit courses_path
      expect(Course.count).to be > 0

      fill_in "Enter Course Name, Number, Section, or Instructor", with: "Dr.richey"
      click_button "Search"
      expect(page).to have_css("td", text: "Dr.richey")
    end
  end
