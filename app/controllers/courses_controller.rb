# frozen_string_literal: true

class CoursesController < ApplicationController
    require "csv"

    def index
      @q = Course.ransack(params[:q])
      sort_column = params[:sort] || "course_name"
      sort_direction = params[:direction] == "desc" ? "desc" : "asc"

      @courses = @q.result(distinct: true).order("#{sort_column} #{sort_direction}")
    end

    def import
      file = params[:csv_file]

      if file.nil?
        redirect_to courses_path, alert: "No file selected"
        return
      end
      begin
        CSV.foreach(file.path, headers: true) do |row|
          Course.create!(
            course_name: row["Course_Name"],
            course_number: row["Course_Number"],
            section: row["Section"],
            instructor: row["Instructor"],
            faculty_email: row["Faculty_Email"],
            ta: row["TA"].to_f,
            senior_grader: row["Senior_Grader"].to_f,
            grader: row["Grader"].to_f,
            pre_reqs: row["Professor Pre_Reqs"]
          )
        end
        redirect_to courses_path, notice: "Courses imported successfully!"
      rescue StandardError => e
        redirect_to courses_path, alert: "Error importing file: #{e.message}"
      end
    end
    def clear
        Course.delete_all
      
        if request
            redirect_to courses_path, notice: "All courses have been deleted."
        else
            puts "All courses have been deleted."
        end
    end

    def export
      @courses = Course.all

      respond_to do |format|
        format.csv do
          send_data generate_csv(@courses), filename: "courses-#{Date.today}.csv"
        end
      end
    end
    private

    def generate_csv(courses)
      CSV.generate(headers: true) do |csv|
        csv << [ "Course Name", "Course Number", "Section", "Instructor", "Faculty Email", "TA", "Senior Grader", "Grader", "Pre-requisites" ]

        courses.each do |course|
          csv << [ course.course_name, course.course_number, course.section, course.instructor, course.faculty_email, course.ta, course.senior_grader, course.grader, course.pre_reqs ]
        end
      end
    end
end
