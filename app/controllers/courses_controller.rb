class CoursesController < ApplicationController
    require 'csv'
  
    def index
      @courses = Course.all
      sort_column = params[:sort] || "course_name" 
      sort_direction = params[:direction] == "desc" ? "desc" : "asc" 
      @courses = Course.order("#{sort_column} #{sort_direction}")

      @q = Course.ransack(params[:q])  
      @courses = @q.result(distinct: true) 
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
            course_name: row['course_name'],
            course_number: row['course_number'],
            section: row['section'],
            instructor: row['instructor'],
            faculty_email: row['faculty_email'],
            ta: row['ta'].to_f,
            senior_grader: row['senior_grader'].to_f,
            grader: row['grader'].to_f,
            pre_reqs: row['pre_reqs']
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
    
end