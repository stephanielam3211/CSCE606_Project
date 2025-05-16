# frozen_string_literal: true

# This controller manages the Course functions of the application
class CoursesController < ApplicationController
  skip_before_action :require_login, if: -> { Rails.env.test? }
  before_action :authorize_admin!, only: [:index, :create, :update, :destroy, :import, :clear]
  require "csv"

  # will sort the courses by the thier columns
  def index
    @q = Course.ransack(params[:q])
    sort_column = params[:sort] || "course_name"
    sort_direction = params[:direction] == "desc" ? "desc" : "asc"

    @courses = @q.result(distinct: true).order("#{sort_column} #{sort_direction}")
    @ta = Course.sum(:ta).to_i
    @senior_grader = Course.sum(:senior_grader).to_i
    @grader = Course.sum(:grader).to_i
    @total = @ta + @senior_grader + @grader

  end

  # Will search for courses based on params
  def search_recs
    courses = Course.where("LOWER(course_name) LIKE ? OR course_number LIKE ?", "%#{params[:term]}%", "%#{params[:term]}%").limit(10)
    render json: courses.map { |course| {
      id: course.id,
      text: "#{course.course_number} - #{course.section}",
      course_number: course.course_number,
      section: course.section,
      name: course.course_name
    }}
  end

  # Will search for courses. Used in the application form for students
  def search
    if params[:term].present?
      courses = Course.where("course_name LIKE ? OR course_number LIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
    else
      courses = Course.all
    end

    render json: courses.map { |c| { id: c.id, name: "#{c.course_number} - #{c.course_name} (Section: #{c.section})" } }
  end

  # Will create a new course
  def create
    @course = Course.new(course_params)
    respond_to do |format|
      if @course.save
        if TaMatch.count > 0 || GraderMatch.count > 0 || SeniorGraderMatch.count > 0
          # Path to the CSV file
          new_needs_path = Rails.root.join("app", "Charizard", "util", "public", "output", "New_Needs.csv")

          # Define fixed headers for the CSV file
          column_order = [ "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email",
                           "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs" ]

          # Check if headers need to be written (write headers only if file doesn't exist)
          write_headers = !File.exist?(new_needs_path)

          # Prepare row values
          row_values = [
            @course.course_name,
            @course.course_number,
            @course.section,
            @course.instructor,
            @course.faculty_email,
            @course.ta,
            @course.senior_grader,
            @course.grader,
            @course.pre_reqs.presence || "N/A"
          ]

          # Append to the CSV file
          CSV.open(new_needs_path, "a", headers: column_order, write_headers: write_headers) do |csv|
            csv << row_values
          end
        end
        format.html { redirect_to courses_path, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
        format.js
      else
        Rails.logger.debug "Course failed to save: #{@course.errors.full_messages}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # Used to update a course
  def update
    # Rails.logger.debug "CSRF Token: #{form_authenticity_token}"
    # Rails.logger.debug "Received Headers: #{request.headers.to_h}"
    # Rails.logger.debug "Params: #{params.inspect}"
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to courses_path, notice: "Course was successfully updated." }
        format.json { render json: { message: "Course updated successfully", id: @course.id }, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Will delete a course
  def destroy
    @course = Course.find(params[:id])
    course_number = @course.course_number
    section = @course.section
    input_courses = course_number.to_s.scan(/\d{3}/).map(&:strip)
    input_sections = section.to_s.scan(/\d+/).map(&:strip)

    TaMatch.where(course_number: input_courses, section: input_sections).find_each do |ta_match|
      add_to_modified_assignments(ta_match)
      backup_unassigned_applicant(ta_match.uin)
      ta_match.destroy
    end

    GraderMatch.where(course_number: input_courses, section: input_sections).find_each do |grader_match|
      add_to_modified_assignments(grader_match)
      backup_unassigned_applicant(grader_match.uin)
      grader_match.destroy
    end
    SeniorGraderMatch.where(course_number: input_courses, section: input_sections).find_each do |senior_grader_match|
      add_to_modified_assignments(senior_grader_match)
      backup_unassigned_applicant(senior_grader_match.uin)
      senior_grader_match.destroy
    end
    remove_course_from_new_needs_csv(course_number, section)
    @course.destroy
    respond_to do |format|
      format.js
      format.html { redirect_to courses_path, notice: "Course was successfully deleted." }
    end
  end
  # Will import a CSV file that will create courses base on the Headers
  # Course_Name, Course_Number, Section, Instructor, Faculty_Email, TA, Senior_Grader, Grader, Professor Pre-Reqs
  def import
    file = params[:csv_file]

    if file.nil?
      redirect_to courses_path, alert: "No file selected"
      return
    end
    begin  
      csv_data = CSV.read(file.path, headers: true)
      normalize_headers = csv_data.headers.map { |h| h.strip.downcase }
      # Process each row, cleaning up the values as well
      csv_data.each do |row|
        row = row.to_h.transform_keys { |key| key.strip.downcase }.transform_values { |value| value.strip if value.respond_to?(:strip) }
        # Create the course with cleaned data
        Course.create!(
          course_name: row["course_name"],
          course_number: row["course_number"],
          section: row["section"],
          instructor: row["instructor"],
          faculty_email: row["faculty_email"],
          ta: row["ta"].to_f,
          senior_grader: row["senior_grader"].to_f,
          grader: row["grader"].to_f,
          pre_reqs: row["professor pre_reqs"]
        )
      end
      redirect_to courses_path, notice: "Courses imported successfully!"
    rescue StandardError => e
      Rails.logger.error "Error importing CSV: #{e.message}"
      Rails.logger.error "Check Headers: #{csv_data.headers.inspect}"
      session[:notice] = "Error importing file: #{e.message}, Check headers for proper capitalization and whitespace"
      redirect_to courses_path, notice: "Error importing CSV: Check headers for proper capitalization and whitespace"
    end
  end

  # Will clear all the courses in the database
  def clear
    Course.delete_all
    if request
      redirect_to root_path, notice: "All courses have been deleted."
    else
      puts "All courses have been deleted."
    end
  end

  def add_to_modified_assignments(model_record)
    path = Rails.root.join("app", "Charizard", "util", "public", "output", "Modified_assignments.csv")
    if model_record.present?
      attributes = model_record.attributes.except("id", "created_at", "updated_at")
      headers = attributes.keys

      write_headers = !File.exist?(path) || File.zero?(path)

      CSV.open(path, "a", write_headers: write_headers, headers: headers) do |csv|
        csv << attributes.values
      end
    end
  end

  def backup_unassigned_applicant(uin)
    applicant = Applicant.find_by(uin: uin)
    return unless applicant

    UnassignedApplicant.create(applicant.attributes.except("id", "created_at", "updated_at", "confirm"))
  end

  def remove_course_from_new_needs_csv(course_number, section)
    path = Rails.root.join("app", "Charizard", "util", "public", "output", "New_Needs.csv")
    return unless File.exist?(path)

    column_order = [ "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email", "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs" ]

    data = CSV.read(path, headers: true).map(&:to_h)
    Rails.logger.debug "Course Number: #{course_number}, Section: #{section}"

    # Filter out matching rows
    filtered_data = data.reject do |row|
      row_course_number = row["Course_Number"].to_s.strip
      row_section = row["Section"].to_s.strip
      if row_course_number == course_number.strip && row_section == section.strip
        Rails.logger.debug "Removing row: #{row.inspect}"
        true
      else
        false
      end
    end

    # Rewrite the CSV with remaining rows
    CSV.open(path, "w", headers: column_order, write_headers: true) do |csv|
      filtered_data.each do |row|
        csv << row.values_at(*column_order)
      end
    end
  end

  private
  def authorize_admin!
    case session[:role].to_s
    when "admin"
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  # Requires course params for creation
  def course_params
    params.require(:course).permit(:course_name, :course_number, :section, :instructor, :faculty_email,
                                   :ta, :senior_grader, :grader, :pre_reqs)
  end
end
