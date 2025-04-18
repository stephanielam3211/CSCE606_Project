# frozen_string_literal: true

# This controller manages the the main assignment process of the application
# It handles the CSV processing, viewing, editing, and updating of TA assignments.
class TaAssignmentsController < ApplicationController
  require "csv"

  # This is the main function that handles the CSV processing for the first time
  def process_csvs
    delete_all_csvs(skip_redirect: true) if File.exist?(Rails.root.join("app/Charizard/util/public/output/TA_Matches.csv"))

    apps_csv = generate_csv_apps(Applicant.all)
    apps_csv_path = Rails.root.join("tmp", "TA_Applicants.csv")
    File.write(apps_csv_path, apps_csv)

    needs_csv = generate_csv_needs(Course.all)
    needs_csv_path = Rails.root.join("tmp", "TA_Needs.csv")
    File.write(needs_csv_path, needs_csv)

    recs_csv = generate_csv_recommendations(Recommendation.all)
    recs_csv_path = Rails.root.join("tmp", "Prof_Prefs.csv")
    File.write(recs_csv_path, recs_csv)

    python_path = `which python3`.strip  # Find Python path dynamically
    system("#{python_path} app/Charizard/main.py '#{apps_csv_path}' '#{needs_csv_path}' '#{recs_csv_path}'")

    flash[:notice] = "CSV processing complete"
    system("rake import:csv")
    redirect_to view_csv_path
  end

  # This method is used to view the CSV files
  def view_csv
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")
    @csv_files = Dir.entries(csv_directory).select { |f| f.end_with?(".csv") }

    if params[:file].present? && @csv_files.include?(params[:file])
      @selected_csv = params[:file]
      @csv_content = read_csv(File.join(csv_directory, @selected_csv))
    end
  end
 
  # This is to edit the assignments and get the data from the model
  def edit
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")

    file_name = params[:file] + ".csv"
    @table_name = params[:file]

    case file_name
    when "ta_matches.csv"
      file_name = "TA_Matches.csv"
    when "senior_grader_matches.csv"
      file_name = "Senior_Grader_Matches.csv"
    when "grader_matches.csv"
      file_name = "Grader_Matches.csv"
    end

    file_path = File.join(csv_directory, file_name)

    @records = read_csv(file_name)
    @record = @records.find { |r| r["UIN"] == params[:uin] }

    if @record.nil?
      redirect_to view_csv_path, alert: "Record not found."
    end
  end

  # This method is used to update the assignments
  def update
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")
    file_key = params[:file].strip.downcase

    if file_key == "ta_matches"
      file_name = "TA_Matches.csv"
    elsif file_key == "senior_grader_matches"
      file_name = "Senior_Grader_Matches.csv"
    elsif file_key == "grader_matches"
      file_name = "Grader_Matches.csv"
    else
      file_name = params[:file] + ".csv"
    end

    csv_mappings = {
      "TA_Matches.csv" => TaMatch,
      "Grader_Matches.csv" => GraderMatch,
      "Senior_Grader_Matches.csv" => SeniorGraderMatch
    }

    model_class = csv_mappings[file_name]
    file_path = File.join(csv_directory, file_name)

    
    records = read_csv(file_name)
    record_index = records.index { |r| r["Course Number"] == params[:course_number] && r["Section ID"] == params[:section] }
    
    Rails.logger.debug "Record index: #{record_index.inspect}"
    Rails.logger.debug "Records: #{records.inspect}"
    modified_class_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Modified_assignments.csv")

    CSV.open(modified_class_csv_path, "a", headers: records.first.keys, write_headers: !File.exist?(modified_class_csv_path)) do |csv|
      if record_index
        csv << records[record_index].values
      end
    end

    uin = records.first["UIN"]

   
    applicant_record = Applicant.find_by(uin: uin)
    Rails.logger.debug "Applicant record: #{applicant_record.inspect}"

    if applicant_record.nil?
      Rails.logger.debug "No applicant record found with UIN: #{uin}"
    else
      UnassignedApplicant.create(applicant_record.attributes.except("id", "created_at", "updated_at","confirm"))
      Rails.logger.debug "Unassigned applicant created: #{applicant_record.inspect}"
    end

    if record_index
      records[record_index]["Student Name"] = params[:stu_name]
      records[record_index]["Student Email"] = params[:stu_email]
      records[record_index]["UIN"] = params[:uin]
      #     Rails.logger.debug "After update: #{records[record_index].inspect}"
      CSV.open(file_path, "w", headers: records.first.keys, write_headers: true) do |csv|
        records.each { |r| csv << r.values }
      end
      model_record = model_class.find_by(course_number: params[:course_number], section: params[:section])
      model_record.update(
        stu_name: params[:stu_name],
        stu_email: params[:stu_email],
        uin: params[:uin]
      )


      add_to_backup_csv = Rails.root.join("app", "Charizard", "util", "public", "output", "Unassigned_Applicants.csv")
          column_order = [
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

          CSV.open(add_to_backup_csv, "a", headers: column_order, write_headers: !File.exist?(add_to_backup_csv)) do |csv|
            if applicant_record.present? && applicant_record.respond_to?(:attributes)
              # Create the row based on the direct mapping
              row_values = column_order.map do |header|
                attribute = direct_mapping[header]  # Get the model attribute for this header
                applicant_record.send(attribute) || ""  # Use the value from the model, or fallback to an empty string if nil
              end
              csv << row_values
            end
          end
      prev_app_record = UnassignedApplicant.find_by(uin: params[:uin])
      if prev_app_record.nil?
        Rails.logger.debug "No applicant record found with UIN: #{params[:uin]}"
      else
        csv_data = CSV.read(add_to_backup_csv, headers: true)
        # Filter out the row with the UIN
        filtered_data = csv_data.reject { |row| row["UIN"].to_i == params[:uin].to_i }
        CSV.open(add_to_backup_csv, "w", write_headers: true, headers: csv_data.headers) do |csv|
          filtered_data.each do |row|
            csv << row
          end
        end
        prev_app_record.destroy
        Rails.logger.debug "Unassigned applicant destroyed: #{prev_app_record.inspect}"
      end

      flash[:notice] = "Student information updated successfully."

    else
      flash[:alert] = "Student record not found."
    end
    Rails.logger.debug "Redirecting to fallback: #{view_csv_path}"

    redirect_to all_records_path(table: "#{params[:file]}")
  end

  def determine_assignment_type(record)
    case record
    when "TA_Matches.csv" then "TA"
    when "Senior_Grader_Matches.csv" then "Senior_Grader"
    when "Grader_Matches.csv" then "Grader"
    end
  end

  # Used to download the CSV files
  def download_csv
    file_name = params[:file]
    file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)
    if File.exist?(file_path)
      send_file file_path, filename: file_name, type: "text/csv", disposition: "attachment"
    else
      redirect_to root_path, alert: "File not found."
    end
  end
  
  # Deletes all of the relevant assignment csvs and models excluding withdrawls
  def delete_all_csvs(skip_redirect: false)
    Dir[Rails.root.join("app/Charizard/util/public/output/*.csv")].each do |file|
      File.delete(file)
    File.delete(Rails.root.join("tmp", "TA_Matches.csv")) if File.exist?(Rails.root.join("tmp", "TA_Matches.csv"))
    File.delete(Rails.root.join("tmp", "Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Grader_Matches.csv"))
    File.delete(Rails.root.join("tmp", "Senior_Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Senior_Grader_Matches.csv"))
    end
    GraderMatch.delete_all
    SeniorGraderMatch.delete_all
    TaMatch.delete_all
    UnassignedApplicant.delete_all

    redirect_to ta_assignments_new_path, notice: "All CSV files and models have been deleted." unless skip_redirect
  end

  # Used to get a final csvs with all of the assignments with relevant applicant data
  def export_final_csv
    headers = [ "Assignment", "Course Number", "Section ID", "Instructor Name",
                "Instructor Email", "Student Name", "Student Email", "UIN", "Phone Number", 
                "Enrollment hours","Degree","Country of Citizenship", "English Certification Level"]

    final_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Assignments(#{Date.today}).csv")

    assignment_header_mapping = {
      "Course Number" => "course_number",
      "Section ID" => "section",
      "Instructor Name" => "ins_name",
      "Instructor Email" => "ins_email",
      "Student Name" => "stu_name",
      "Student Email" => "stu_email",
      "UIN"=> "uin",
    }

    models = {
      "TA" => TaMatch,
      "Grader" => GraderMatch,
      "Senior Grader" => SeniorGraderMatch
    }

    applicants_by_uin = Applicant.all.index_by { |applicant| applicant.uin.to_s }

    CSV.open(final_csv_path, "w") do |csv|
      csv << headers
      models.each do |assignment_type, model|
        model.find_each do |assignment|
          uin = assignment.uin.to_i
          applicant = applicants_by_uin[uin.to_s]
          Rails.logger.debug("Applicant: #{applicant.inspect}")

          row_data = headers.map do |header|
            case header
            when "Assignment"
              assignment_type
            when *assignment_header_mapping.keys
              assignment.send(assignment_header_mapping[header])
            when "Phone Number"
              applicant.number
            when "Enrollment hours"
              applicant.hours
            when "Degree"
              applicant.degree
            when "Country of Citizenship"
              applicant.citizenship
            when "English Certification Level"
              applicant.cert
            else
              ""
            end
          end
          csv << row_data
        end
      end
    end
  
    flash[:notice] = "Assignments.csv has been successfully created!"
    send_file final_csv_path, filename: "Assignments(#{Date.today}).csv", type: "text/csv", disposition: "attachment"
  end
end

  private
  def save_uploaded_file(file)
    path = Rails.root.join("tmp", file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
    path
  end

  def read_csv(file_name)
    csv_data = []
    file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)
    CSV.foreach(file_path, headers: true) do |row|
      csv_data << row.to_h
    end
    csv_data
  end

  # This method is used to generate the CSV files for the needs
  def generate_csv_needs(records)
    CSV.generate(headers: true) do |csv|
    csv << [ "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email", "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs" ]
    records.each do |record|
      csv << [
        record.course_name,
        record.course_number,
        record.section,
        record.instructor,
        record.faculty_email,
        record.ta.to_f,
        record.senior_grader.to_f,
        record.grader.to_f,
        record.pre_reqs || "N/A"
      ]
      end
    end
  end

  # This method is used to generate the CSV files for the recommendations
  def generate_csv_recommendations(records)
    CSV.generate(headers: true) do |csv|
      csv << [ "Timestamp", "Email Address", "Your Name (first and last)", "Select a TA/Grader", "Course (e.g. CSCE 421)", "Feedback", "Additional Feedback about this student" ]
      records.each do |record|
        csv << [
          record.created_at.strftime("%m/%d/%Y %H:%M:%S"),
          record.email,
          record.name,
          record.selectionsTA,
          record.course,
          record.feedback,
          record.additionalfeedback
        ]
      end
    end
  end

  # This method is used to generate the CSV files for the applications
  def generate_csv_apps(records)
    CSV.generate(headers: true) do |csv|
    csv << [ "Timestamp", "Email Address", "First and Last Name", "UIN", "Phone Number", "How many hours do you plan to be enrolled in?", "Degree Type?", "1st Choice Course", "2nd Choice Course", "3rd Choice Course", "4th Choice Course", "5th Choice Course", "6th Choice Course", "7th Choice Course", "8th Choice Course", "9th Choice Course", "10th Choice Course", "GPA", "Country of Citizenship?", "English language certification level?", "Which courses have you taken at TAMU?", "Which courses have you taken at another university?", "Which courses have you TAd for?", "Who is your advisor (if applicable)?", "What position are you applying for?" ]
    records.each do |record|
      blacklist_entry = Blacklist.find_by(
        'LOWER(student_name) = ? AND LOWER(student_email) = ?',
        record.name.downcase,
        record.email.downcase
      )
      next if blacklist_entry
      csv << [
        record.timestamp,
        record.email,
        record.name,
        record.uin.to_i,
        record.number,
        record.hours.to_i,
        record.degree,
        record.choice_1.to_i,
        record.choice_2.to_i,
        record.choice_3.to_i,
        record.choice_4.to_i,
        record.choice_5.to_i,
        record.choice_6.to_i,
        record.choice_7.to_i,
        record.choice_8.to_i,
        record.choice_9.to_i,
        record.choice_10.to_i,
        record.gpa.to_f,
        record.citizenship,
        record.cert.to_i,
        record.prev_course,
        record.prev_uni,
        record.prev_ta,
        record.advisor,
        record.positions
      ]
      end
    end
  end
