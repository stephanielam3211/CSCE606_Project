# frozen_string_literal: true

class TaAssignmentsController < ApplicationController
  require "csv"

  def process_csvs
    delete_all_csvs(skip_redirect: true)  if File.exist?(Rails.root.join("app/Charizard/util/public/output/TA_Matches.csv"))

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

  def view_csv
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")
    @csv_files = Dir.entries(csv_directory).select { |f| f.end_with?(".csv") }

    if params[:file].present? && @csv_files.include?(params[:file])
      @selected_csv = params[:file]
      @csv_content = read_csv(File.join(csv_directory, @selected_csv))
    end
  end

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
      flash[:notice] = "Student information updated successfully."
    else
      flash[:alert] = "Student record not found."
    end
    Rails.logger.debug "Redirecting to fallback: #{view_csv_path}"

    redirect_to all_records_path(table: "#{params[:file]}")
  end

  def destroy
    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")
    file_name = params[:file] + ".csv"

    case file_name
    when "ta_matches.csv"
      file_name = "TA_Matches.csv"
    when "senior_grader_matches.csv"
      file_name = "Senior_Grader_Matches.csv"
    when "grader_matches.csv"
      file_name = "Grader_Matches.csv"
    end

    csv_mappings = {
      "TA_Matches.csv" => TaMatch,
      "Grader_Matches.csv" => GraderMatch,
      "Senior_Grader_Matches.csv" => SeniorGraderMatch
    }
    model_class = csv_mappings[file_name]
    Rails.logger.debug "Model class for #{file_name}: #{model_class.inspect}"

    if model_class.nil?
      Rails.logger.error "No model class found for file: #{file_name}"
      flash[:alert] = "No model found for file #{file_name}."
      redirect_to view_csv_path and return
    end

    Recommendation.create(
      email: "#{params[:ins_email]}",
      name: "#{params[:ins_name]}",
      course: "CSCE #{params[:course_number]}",
      selectionsTA: "#{params[:stu_name]} (#{params[:stu_email]})",
      feedback: "I do not want to work with this student"
    )

    file_path = File.join(csv_directory, file_name)

    records = read_csv(file_name)
    record = records.find do |r|
      r["UIN"] == params[:uin]
    end

    Rails.logger.error "record not found with uin #{params[:uin]}" if record.nil?

    if record

      modified_class_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Modified_assignments.csv")
      CSV.open(modified_class_csv_path, "a", headers: records.first.keys, write_headers: !File.exist?(modified_class_csv_path)) do |csv|
        csv << record.values
      end
      records.reject! { |r| r["UIN"] == params[:uin] }

      # Save the updated data to the new CSV file
      if records.empty?
        CSV.open(file_path, "w", headers: record.keys, write_headers: true) do |csv|
        end
      else
        CSV.open(file_path, "w", headers: records.first.keys, write_headers: true) do |csv|
          records.each { |r| csv << r.values }
        end
      end

      model_record = model_class&.find_by(uin: params[:uin])
      if model_record.nil?
        Rails.logger.debug "No record found with UIN: #{params[:uin]}"
      else
        model_class1 = Applicant
        model_record1 = model_class1&.find_by(uin: params[:uin])
        if model_record1.nil?
          Rails.logger.debug "No record found with UIN: #{params[:uin]}"
        else
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
            if model_record1.present? && model_record1.respond_to?(:attributes)
              # Create the row based on the direct mapping
              row_values = column_order.map do |header|
                attribute = direct_mapping[header]  # Get the model attribute for this header
                model_record1.send(attribute) || ""  # Use the value from the model, or fallback to an empty string if nil
              end
              csv << row_values
            end
          end
        end

        model_class2 = Course
        model_record2 = model_class2.where("course_number LIKE ?", "%#{params[:course_number]}%")
          .where("section LIKE ?", "%#{params[:section]}%").first
        if model_record2.nil?
          Rails.logger.debug "No record found with section: #{params[:section]} and course_number: #{params[:course_number]}"
        else
          assignment_type = determine_assignment_type(file_name)

          add_to_new_needs_csv = Rails.root.join("app", "Charizard", "util", "public", "output", "New_Needs.csv")
          column_order = [
            "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email",
            "TA", "Senior_Grader", "Grader", "Professor Pre-Reqs"
          ]

          write_headers = !File.exist?(add_to_new_needs_csv)
          existing_data = []
          if File.exist?(add_to_new_needs_csv)
            CSV.foreach(add_to_new_needs_csv, headers: true) do |row|
              existing_data << row.to_h
            end
          end
          course_entry = existing_data.find do |row|
            row["Course_Number"] == model_record2.course_number && row["Section"] == model_record2.section
          end
          if course_entry
            current_value = course_entry[assignment_type].to_i
            course_entry[assignment_type] = (current_value + 1).to_s
          else
            new_entry = {
              "Course_Name" => model_record2.course_name,
              "Course_Number" => model_record2.course_number,
              "Section" => model_record2.section,
              "Instructor" => model_record2.instructor,
              "Faculty_Email" => model_record2.faculty_email,
              "TA" => "0", "Senior_Grader" => "0", "Grader" => "0",
              "Professor Pre-Reqs" => model_record2.pre_reqs.presence || "N/A"
            }
            new_entry[assignment_type] = "1"
            existing_data << new_entry
          end
          Rails.logger.debug "Updated CSV Data: #{new_entry.inspect}"

          # Write back to CSV
          CSV.open(add_to_new_needs_csv, "w", write_headers: true, headers: column_order) do |csv|
            existing_data.each { |row| csv << row.values_at(*column_order) }
          end
        end
      end
      model_record.destroy
      Rails.logger.debug "Record with UIN #{params[:uin]} destroyed."
      flash[:notice] = "Student record deleted. Class details saved separately."
    else
      flash[:alert] = "Student record with UIN #{params[:uin]} not found."
    end
    redirect_back(fallback_location: view_csv_path)
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
    # Update original CSV (remove unconfirmed)
    records.reject! { |r| uins.include?(r["UIN"]) }  
    CSV.open(file_path, "w", headers: records.first&.keys || [], write_headers: true) do |csv|
      records.each { |r| csv << r.values }
    end  
    # Add removed to Modified_assignments
    CSV.open(modified_csv, "a", headers: records.first&.keys || [], write_headers: !File.exist?(modified_csv)) do |csv|
      uins.each do |uin|
        record = uin_to_record_map[uin]
        csv << record.values if record
      end
    end  
      uins.each do |uin|
        model_record = model_class.find_by(uin: uin)
        next unless model_record
  
        # Add to Unassigned_Applicants.csv
        applicant = Applicant.find_by(uin: uin)
        if applicant
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
            if model_record.present? && model_record.respond_to?(:attributes)
              # Create the row based on the direct mapping
              row_values = new_column_order.map do |header|
                attribute = direct_mapping[header]  # Get the model attribute for this header
                model_record.send(attribute) || ""  # Use the value from the model, or fallback to an empty string if nil
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
          feedback: "I do not want to work with this student"
        )

      end

      flash[:notice] = "All unconfirmed assignments were deleted and processed."
      redirect_back fallback_location: view_csv_path
      end

  def determine_assignment_type(record)
    case record
    when "TA_Matches.csv" then "TA"
    when "Senior_Grader_Matches.csv" then "Senior_Grader"
    when "Grader_Matches.csv" then "Grader"
    end
  end


  def download_csv
    file_name = params[:file]
    file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)
    if File.exist?(file_path)
      send_file file_path, filename: file_name, type: "text/csv", disposition: "attachment"
    else
      redirect_to root_path, alert: "File not found."
    end
  end

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

    redirect_to ta_assignments_new_path, notice: "All CSV files and models have been deleted." unless skip_redirect
  end

  def export_final_csv
    headers = [ "Course Number", "Section ID", "Instructor Name", "Instructor Email", "Student Name", "Student Email", "Calculated Score" ]
    final_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Assignments.csv")

    CSV.open(final_csv_path, "w") do |csv|
      csv << headers
      [ "TA_Matches.csv", "Grader_Matches.csv", "Senior_Grader_Matches.csv" ].each do |file_name|
        file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)
        if File.exist?(file_path)
          CSV.foreach(file_path, headers: true) do |row|
            csv << row.values_at(*headers)
          end
        else
          Rails.logger.error "File not found: #{file_name}"
        end
      end
    end

    flash[:notice] = "Assignments.csv has been successfully created!"
    redirect_to view_csv_path
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

  def generate_csv_recommendations(records)
    CSV.generate(headers: true) do |csv|
      csv << ["Timestamp", "Email Address", "Your Name (first and last)", "Select a TA/Grader", "Course (e.g. CSCE 421)", "Feedback", "Additional Feedback about this student"]
      records.each do |record|
        csv << [
          record.created_at.strftime('%m/%d/%Y %H:%M:%S'),
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


  def generate_csv_apps(records)
    CSV.generate(headers: true) do |csv|
    csv << [ "Timestamp", "Email Address", "First and Last Name", "UIN", "Phone Number", "How many hours do you plan to be enrolled in?", "Degree Type?", "1st Choice Course", "2nd Choice Course", "3rd Choice Course", "4th Choice Course", "5th Choice Course", "6th Choice Course", "7th Choice Course", "8th Choice Course", "9th Choice Course", "10th Choice Course", "GPA", "Country of Citizenship?", "English language certification level?", "Which courses have you taken at TAMU?", "Which courses have you taken at another university?", "Which courses have you TAd for?", "Who is your advisor (if applicable)?", "What position are you applying for?" ]
    records.each do |record|
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
