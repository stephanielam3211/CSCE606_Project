# frozen_string_literal: true

class RecordsController < ApplicationController
  before_action :authorize_admin!
  # Gets the records from the database
  def index
    @table_name = params[:table]
    case @table_name
    when "grader_matches"
      @records = GraderMatch.all
    when "recommendations"
      @records = Recommendation.all
    when "senior_grader_matches"
      @records = SeniorGraderMatch.all
    when "ta_matches"
      @records = TaMatch.all
    else
      @records = []
    end
    @records = @records.sort_by { |r| r.confirm ? 0 : 1 } if @records.present?

    @ta = Course.sum(:ta).to_i
    @senior_grader = Course.sum(:senior_grader).to_i
    @grader = Course.sum(:grader).to_i
  end

  # Admin function to toggle assignment
  def toggle_assignment
    model = params[:table].classify.constantize
    record = model.find(params[:id])
    record.update(assigned: !record.assigned)
    redirect_back fallback_location: root_path
  end

  # Admin function to revoke assignment
  def revoke_assignment
    model = params[:table].classify.constantize
    record = model.find(params[:id])
    # record.update(confirm: false)
    record.assigned = false
    record.confirm = false
    record.save!
    redirect_back(fallback_location: request.referer || root_path)
  end

  # Admin function to mass unconfirm assignment
  def mass_confirm
    model = params[:table].classify.constantize
    model.find_each { |record|
      record.update(confirm: false)
    }
    redirect_back(fallback_location: request.referer || root_path)
  end

  # Admin function to mass toggle assignment send
  def mass_toggle_assignment
    model = params[:table].classify.constantize
    if model.where(assigned: true).exists?
      model.find_each { |record|
      record.update(assigned: false)
      }
      notice = "All assignments have been unsent."
    else
      model.find_each { |record|
      record.update(assigned: true)
      }
      notice = "All assignments have been sent."
    end
    redirect_back(fallback_location: request.referer || root_path)
  end

  def destroy_unconfirmed
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")

    case params[:type]
    when "ta_matches"
      file_name = "TA_Matches.csv"
      model_class = TaMatch
    when "grader_matches"
      file_name = "Grader_Matches.csv"
      model_class = GraderMatch
    when "senior_grader_matches"
      file_name = "Senior_Grader_Matches.csv"
      model_class = SeniorGraderMatch
    else
      flash[:alert] = "Invalid type"
      redirect_back fallback_location: view_csv_path and return
    end

    Rails.logger.debug "File name: #{file_name}, Model class: #{model_class}"

    file_path = Rails.root.join(csv_directory, file_name)
    modified_csv = Rails.root.join(csv_directory, "Modified_assignments.csv")
    add_to_backup_csv = Rails.root.join(csv_directory, "Unassigned_Applicants.csv")
    new_needs_csv = Rails.root.join(csv_directory, "New_Needs.csv")

    records = read_csv(file_name)

    unconfirmed = model_class.where(confirm: false)

    if unconfirmed.empty?
      Rails.logger.info "No unconfirmed assignments found"
      flash[:alert] = "No unconfirmed assignments found."
      redirect_back fallback_location: view_csv_path and return
    end

    uin_to_record_map = records.index_by { |r| r["UIN"] }
    uins = unconfirmed.pluck(:uin)

    headers = records.first.keys

      # Add removed records to Modified_assignments
      CSV.open(modified_csv, "a", headers: headers, write_headers: !File.exist?(modified_csv)) do |csv|
        uins.each do |uin|
          model_record = model_class.find_by(uin: uin)
          next unless model_record

          # Convert to string-keyed hash and rename keys to match CSV headers
          row_data = {
            "Course Number" => model_record.course_number,
            "Section ID" => model_record.section,
            "Instructor Name" => model_record.ins_name,
            "Instructor Email" => model_record.ins_email,
            "Student Name" => model_record.stu_name,
            "Student Email" => model_record.stu_email,
            "UIN" => model_record.uin.to_s,
            "Calculated Score" => model_record.score
          }

          csv << headers.map { |h| row_data[h] }
        end
      end
    # Update original CSV (remove unconfirmed)
    records.reject! { |r| uins.include?(r["UIN"]) }
    CSV.open(file_path, "w", headers: records.first&.keys || [], write_headers: true) do |csv|
      records.each { |r| csv << r.values }
    end
      # Add removed to Modified_assignments
      # CSV.open(modified_csv, "a", headers: records.first&.keys || [], write_headers: !File.exist?(modified_csv)) do |csv|
      #   uins.each do |uin|
      #     record = uin_to_record_map[uin]
      #     csv << record.values if record
      #   end
      # end


      uins.each do |uin|
        model_record = model_class.find_by(uin: uin)
        next unless model_record

        # Add to Unassigned_Applicants.csv
        applicant = Applicant.find_by(uin: uin)
        if applicant
          UnassignedApplicant.create(applicant.attributes.except("id", "created_at", "updated_at", "confirm"))
          applicant_headers = [
            "Timestamp", "Email Address", "First and Last Name", "UIN", "Phone Number", "How many hours do you plan to be enrolled in?",
            "Degree Type?", "1st Choice Course", "2nd Choice Course", "3rd Choice Course", "4th Choice Course", "5th Choice Course",
            "6th Choice Course", "7th Choice Course", "8th Choice Course", "9th Choice Course", "10th Choice Course", "GPA",
            "Country of Citizenship?", "English language certification level?", "Which courses have you taken at TAMU?",
            "Which courses have you taken at another university?", "Which courses have you TAd for?", "Who is your advisor (if applicable)?",
            "What position are you applying for?"
          ]
          direct_mapping = {
            "Timestamp" => "timestamp",
            "Email Address" => "email",
            "First and Last Name" => "name",
            "UIN" => "uin",
            "Phone Number" => "number",
            "How many hours do you plan to be enrolled in?" => "hours",
            "Degree Type?" => "degree",
            "1st Choice Course" => "choice_1",
            "2nd Choice Course" => "choice_2",
            "3rd Choice Course" => "choice_3",
            "4th Choice Course" => "choice_4",
            "5th Choice Course" => "choice_5",
            "6th Choice Course" => "choice_6",
            "7th Choice Course" => "choice_7",
            "8th Choice Course" => "choice_8",
            "9th Choice Course" => "choice_9",
            "10th Choice Course" => "choice_10",
            "GPA" => "gpa",
            "Country of Citizenship?" => "citizenship",
            "English language certification level?" => "cert",
            "Which courses have you taken at TAMU?" => "prev_course",
            "Which courses have you taken at another university?" => "prev_uni",
            "Which courses have you TAd for?" => "prev_ta",
            "Who is your advisor (if applicable)?" => "advisor",
            "What position are you applying for?" => "positions"
          }

          CSV.open(add_to_backup_csv, "a", headers: applicant_headers, write_headers: !File.exist?(add_to_backup_csv)) do |csv|
            if applicant.present? && applicant.respond_to?(:attributes)
              # Create the row based on the direct mapping
              row_values = applicant_headers.map do |header|
                attribute = direct_mapping[header]  # Get the model attribute for this header
                applicant.send(attribute) || ""  # Use the value from the model, or fallback to an empty string if nil
              end
              csv << row_values
            end
          end
        end

        # Update New_Needs.csv
        course = Course.where("course_number LIKE ?", "%#{model_record.course_number}%")
                       .where("section LIKE ?", "%#{model_record.section}%").first
        if course
          assignment_type = determine_assignment_type(file_name)

          column_order = [
            "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email",
            "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs"
          ]

          existing_data = []
          if File.exist?(new_needs_csv)
            CSV.foreach(new_needs_csv, headers: true) { |row| existing_data << row.to_h }
          end

          entry = existing_data.find { |r| r["Course_Number"] == course.course_number && r["Section"] == course.section }

          if entry
            current_val = entry[assignment_type].to_i
            entry[assignment_type] = (current_val + 1).to_s
          else
            new_entry = {
              "Course_Name" => course.course_name,
              "Course_Number" => course.course_number,
              "Section" => course.section,
              "Instructor" => course.instructor,
              "Faculty_Email" => course.faculty_email,
              "TA" => "0", "Senior_Grader" => "0", "Grader" => "0",
              "Professor Pre-Reqs" => course.pre_reqs.presence || "N/A"
            }
            new_entry[assignment_type] = "1"
            existing_data << new_entry
          end

          CSV.open(new_needs_csv, "w", headers: column_order, write_headers: true) do |csv|
            existing_data.each { |row| csv << row.values_at(*column_order) }
          end
        end

        # Create Recommendation
        Recommendation.create(
          email: model_record.ins_email,
          name: model_record.ins_name || "admin",
          course: "CSCE #{model_record.course_number}",
          selectionsTA: "#{model_record.stu_name} (#{model_record.stu_email})",
          feedback: "I do not want to work with this student",
          additionalfeedback: "Auto Generated by Admin for Algorithm",
          admin: true
        )
      end
      model_class.where(uin: uins).destroy_all

      flash[:notice] = "All unconfirmed assignments were deleted and processed."
      redirect_back fallback_location: view_csv_path
  end

  # This method is used to delete a record from the database
  def destroy
    file_name = normalize_filename(params[:file])
    model_class = model_class_for(file_name)  # This gets the model based on file name

    unless model_class
      Rails.logger.error "No model class found for file: #{file_name}"
      flash[:alert] = "No model found for file #{file_name}."
      redirect_to view_csv_path and return
    end

    # This creates a recommendation so the algorithm knows will not to reassign the same assignment
    @role = model_class.find(params[:id])
    if @role.nil?
      Rails.logger.error "No Role: #{@role.inspect}"
      flash[:alert] = "No Role: #{@role.inspect}"
      redirect_to all_records_path(table: "ta_matches") and return
    end
    Rails.logger.debug "Role: #{@role.inspect}"
    create_recommendation(@role)

    # This is created if the student denys the position
    create_withdrawal_request(@role) if params[:deny].present?

    # get the record from the csv file
    record = find_record_in_csv(file_name, @role.uin)
    if record.nil?
      flash[:alert] = "Student record with UIN #{@role.uin} not found."
      Rails.logger.error "Record not found with UIN #{@role.uin}"
      return
    end
    # move the record to the modified assignments csv and remove it from the original csv
    move_to_modified_assignments(file_name, record)
    update_csv(file_name, @role.uin)

    # Find the record in the DB
    model_record = model_class.find_by(uin: @role.uin)
    if model_record
      # This creates a backup of the unassigned applicant in DB and csv
      # Then the new course needs file is updated and the record is deleted
      backup_unassigned_applicant(@role.uin)
      update_new_needs_csv(file_name, @role.course_number, @role.section)
      model_record.destroy
      flash[:notice] = "Student record deleted. Class details saved separately."

      respond_to do |format|
        format.js
        format.html { redirect_to all_records_path(table: "ta_matches") }
      end
      Rails.logger.debug "Record with UIN #{@role.uin} destroyed."
    else
      Rails.logger.debug "No record found with UIN #{@role.uin}"
    end
  end

  private
  def authorize_admin
    case session[:role].to_s
    when "admin"
    else
      redirect_to root_path, alert: "Unauthorized access."
    end
  end

  def un_confirmed_params(type)
    case type
    when "ta_matches"
      { file_name: "TA_Matches.csv", model_class: TaMatch }
    when "grader_matches"
      { file_name: "Grader_Matches.csv", model_class: GraderMatch }
    when "senior_grader_matches"
      { file_name: "Senior_Grader_Matches.csv", model_class: SeniorGraderMatch }
    else
      flash[:alert] = "Invalid type"
      redirect_back fallback_location: view_csv_path and return
    end
  end

  # Used to transform the file name to the correct format
  def normalize_filename(file_param)
    case "#{file_param}.csv"
    when "ta_matches.csv" then "TA_Matches.csv"
    when "senior_grader_matches.csv" then "Senior_Grader_Matches.csv"
    when "grader_matches.csv" then "Grader_Matches.csv"
    else "#{file_param}.csv"
    end
  end

  # Used to get the model class based on the file name
  def model_class_for(file_name)
    {
      "TA_Matches.csv" => TaMatch,
      "Grader_Matches.csv" => GraderMatch,
      "Senior_Grader_Matches.csv" => SeniorGraderMatch
    }[file_name]
  end

  # this creastes a recommendation based on the params
  def create_recommendation(role)
    Recommendation.create(
      email: role.ins_email,
      name: role.ins_name,
      course: "CSCE #{role.course_number}",
      selectionsTA: "#{role.stu_name} (#{role.stu_email})",
      feedback: "I do not want to work with this student",
      additionalfeedback: "Auto Generated by Admin for Algorithm",
      admin: true
    )
  end

  # This method is used to create a withdrawal request
  def create_withdrawal_request(role)
    request = WithdrawalRequest.create(
      student_email: role.stu_email,
      student_name: role.stu_name,
      course_number: role.course_number,
      section_id: role.section,
      instructor_email: role.ins_email,
      instructor_name: role.ins_name,
    )

    if request.persisted?
      flash[:notice] = "TA assignment deleted and withdrawal request created."
    else
      flash[:alert] = "TA assignment deleted, but unable to create withdrawal request."
    end
  end

  # This finds a record in the csv file based on the uin
  def find_record_in_csv(file_name, uin)
    records = read_csv(file_name)
    records.find { |r| r["UIN"] == uin }
  end

  # This adds the record to the modified assignments csv
  def move_to_modified_assignments(file_name, record)
    path = Rails.root.join("app", "Charizard", "util", "public", "output", "Modified_assignments.csv")
    CSV.open(path, "a", headers: record.keys, write_headers: !File.exist?(path)) do |csv|
      csv << record.values
    end
  end

  # This removes the recoord form the previous cvs file
  def update_csv(file_name, uin)
    records = read_csv(file_name).reject { |r| r["UIN"] == uin }
    file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)

    CSV.open(file_path, "w", headers: records.first&.keys || [], write_headers: true) do |csv|
      records.each { |r| csv << r.values }
    end
  end

  # This adds the student in the unassigned applicants table and cvs
  def backup_unassigned_applicant(uin)
    applicant = Applicant.find_by(uin: uin)
    return unless applicant

    UnassignedApplicant.create(applicant.attributes.except("id", "created_at", "updated_at", "confirm"))

    column_order, mapping = backup_applicant_column_mapping
    backup_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Unassigned_Applicants.csv")

    CSV.open(backup_path, "a", headers: column_order, write_headers: !File.exist?(backup_path)) do |csv|
      row = column_order.map { |h| applicant.send(mapping[h]) || "" }
      csv << row
    end
  end

  # This is the column mappiing for adding a student to the unassigned applicants csv
  # This is needed beacuse the table and the csv have different column names
  def backup_applicant_column_mapping
    column_order = [
      "Timestamp", "Email Address", "First and Last Name", "UIN", "Phone Number", "How many hours do you plan to be enrolled in?",
      "Degree Type?", "1st Choice Course", "2nd Choice Course", "3rd Choice Course", "4th Choice Course", "5th Choice Course",
      "6th Choice Course", "7th Choice Course", "8th Choice Course", "9th Choice Course", "10th Choice Course", "GPA",
      "Country of Citizenship?", "English language certification level?", "Which courses have you taken at TAMU?",
      "Which courses have you taken at another university?", "Which courses have you TAd for?", "Who is your advisor (if applicable)?",
      "What position are you applying for?"
    ]

    mapping = {
      "Timestamp" => "timestamp", "Email Address" => "email", "First and Last Name" => "name", "UIN" => "uin",
      "Phone Number" => "number", "How many hours do you plan to be enrolled in?" => "hours", "Degree Type?" => "degree",
      "1st Choice Course" => "choice_1", "2nd Choice Course" => "choice_2", "3rd Choice Course" => "choice_3",
      "4th Choice Course" => "choice_4", "5th Choice Course" => "choice_5", "6th Choice Course" => "choice_6",
      "7th Choice Course" => "choice_7", "8th Choice Course" => "choice_8", "9th Choice Course" => "choice_9",
      "10th Choice Course" => "choice_10", "GPA" => "gpa", "Country of Citizenship?" => "citizenship",
      "English language certification level?" => "cert", "Which courses have you taken at TAMU?" => "prev_course",
      "Which courses have you taken at another university?" => "prev_uni", "Which courses have you TAd for?" => "prev_ta",
      "Who is your advisor (if applicable)?" => "advisor", "What position are you applying for?" => "positions"
    }

    [ column_order, mapping ]
  end

  # This updates the new needs file accordingly
  # THe new_needs file need to be updated base on the open position it has for each job
  # So it updates the TA, Senior Grader and Grader columns with the correct number based on the file name
  def update_new_needs_csv(file_name, course_number, section)
    course = Course.where("course_number LIKE ?", "%#{course_number}%")
                   .where("section LIKE ?", "%#{section}%")
                   .first
    return unless course

    assignment_type = determine_assignment_type(file_name)
    path = Rails.root.join("app", "Charizard", "util", "public", "output", "New_Needs.csv")
    column_order = [ "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email", "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs" ]

    data = File.exist?(path) ? CSV.read(path, headers: true).map(&:to_h) : []
    entry = data.find { |row| row["Course_Number"] == course.course_number && row["Section"] == course.section }

    if entry
      entry[assignment_type] = (entry[assignment_type].to_i + 1).to_s
    else
      new_entry = {
        "Course_Name" => course.course_name,
        "Course_Number" => course.course_number,
        "Section" => course.section,
        "Instructor" => course.instructor,
        "Faculty_Email" => course.faculty_email,
        "TA" => "0", "Senior_Grader" => "0", "Grader" => "0",
        "Professor Pre-Reqs" => course.pre_reqs.presence || "N/A"
      }
      new_entry[assignment_type] = "1"
      data << new_entry
    end

    CSV.open(path, "w", headers: column_order, write_headers: true) do |csv|
      data.each { |row| csv << row.values_at(*column_order) }
    end
  end

  # THis is for the new needs file that will get the file and respond with the corresponding column
  def determine_assignment_type(file_name)
    {
      "TA_Matches.csv" => "TA",
      "Senior_Grader_Matches.csv" => "Senior_Grader",
      "Grader_Matches.csv" => "Grader"
    }[file_name]
  end

  def determine_assignment_type1(record)
    case record
    when "TA_Matches.csv" then "TA"
    when "Senior_Grader_Matches.csv" then "Senior_Grader"
    when "Grader_Matches.csv" then "Grader"
    end
  end
end
