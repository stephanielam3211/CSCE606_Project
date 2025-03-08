# frozen_string_literal: true

class TaAssignmentsController < ApplicationController
  require "csv"

  def process_csvs
    if params[:file3].present?

      apps_csv = generate_csv_apps(Applicant.all)
      apps_csv_path = Rails.root.join("tmp", "TA_Applicants.csv")
      File.write(apps_csv_path, apps_csv)

      needs_csv = generate_csv_needs(Course.all)
      needs_csv_path = Rails.root.join("tmp", "TA_Needs.csv")
      File.write(needs_csv_path, needs_csv)

      file3_path = save_uploaded_file(params[:file3])

      python_path = `which python3`.strip  # Find Python path dynamically
      system("#{python_path} app/Charizard/main.py '#{apps_csv_path}' '#{needs_csv_path}' '#{file3_path}'")

      flash[:notice] = "CSV processing complete"
      system("rake import:csv")
      redirect_to view_csv_path
    else
      flash[:alert] = "Please upload all 3 CSV files."
      redirect_to ta_assignments_new_path
    end
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
      "TA_Matches.csv"
    when "senior_grader_matches.csv"
      "Senior_Grader_Matches.csv"
    when "grader_matches.csv"
      "Grader_Matches.csv"
    end

    file_path = File.join(csv_directory, file_name)

    @records = read_csv(file_path)
    @record = @records.find { |r| r["UIN"] == params[:uin] }

    if @record.nil?
      redirect_to view_csv_path, alert: "Record not found."
    end
  end

  def update
    Rails.logger.debug "Received params: #{params.inspect}"

    csv_directory = Rails.root.join("app", "Charizard", "util", "public", "output")
    Rails.logger.debug "Raw params[:file]: '#{params[:file]}'"
    Rails.logger.debug "Stripped params[:file]: '#{params[:file].strip}'"
    Rails.logger.debug "Downcased params[:file]: '#{params[:file].strip.downcase}'"

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
    #   Rails.logger.debug "checking filepath: #{params[:file]}"
    file_path = File.join(csv_directory, file_name)
    #    Rails.logger.debug "checking filepath: #{file_path}"
    records = read_csv(file_path)
    #   Rails.logger.debug "Params UIN: #{params[:uin]}"
    #    Rails.logger.debug "File Path: #{file_path}"
    #    Rails.logger.debug "Loaded Records: #{params[:course_number]}"
    #    Rails.logger.debug "Available UINs in CSV: #{params[:section]}"
    record_index = records.index { |r| r["Course Number"] == params[:course_number] && r["Section ID"] == params[:section] }

    if record_index.nil?
    #      Rails.logger.debug "No record found for UIN: #{params[:uin]}"
    else
      #      Rails.logger.debug "Record found at index: #{record_index}"
      #      Rails.logger.debug "Before update: #{records[record_index].inspect}"
    end

    if record_index
      #     Rails.logger.debug "Record found at index: #{record_index}"
      #     Rails.logger.debug "Before update: #{records[record_index].inspect}"
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

    redirect_back(fallback_location: view_csv_path)
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
    # file_name = "TA_Matches.csv" if file_name == "ta_matches.csv"

    csv_mappings = {
      "TA_Matches.csv" => TaMatch,
      "Grader_Matches.csv" => GraderMatch,
      "Senior_Grader_Matches.csv" => SeniorGraderMatch
    }
    model_class = csv_mappings[file_name]
    Rails.logger.debug "Model class for #{file_name}: #{model_class.inspect}"

    # Log error if model_class is nil
    if model_class.nil?
      Rails.logger.error "No model class found for file: #{file_name}"
      flash[:alert] = "No model found for file #{file_name}."
      redirect_to view_csv_path and return
    end


    file_path = File.join(csv_directory, file_name)

    records = read_csv(file_path)
    record = records.find do |r|
      r["UIN"] == params[:uin]
    end

    # Log an error if the record is not found
    Rails.logger.error "record not found with uin #{params[:uin]}" if record.nil?

    if record
      Rails.logger.debug "Received UIN: #{params[:uin]}"

      Rails.logger.debug "Before Deletion: #{records.count} records"
      records.reject! { |r| r["UIN"] == params[:uin] }
      Rails.logger.debug "After Deletion: #{records.count} records"

      modified_class_csv_path = Rails.root.join("app", "Charizard", "util", "public", "output", "Modified_assignments.csv")

      # Save the updated data to the new CSV file
      CSV.open(file_path, "w", headers: records.first.keys, write_headers: true) do |csv|
        records.each { |r| csv << r.values }
      end

      CSV.open(modified_class_csv_path, "a", headers: records.first.keys, write_headers: !File.exist?(modified_class_csv_path)) do |csv|
        csv << record.values
      end

      Rails.logger.debug "Searching for record with UIN: #{params[:uin]}"
      Rails.logger.debug "Received params: #{params.inspect}"
      model_record = model_class.find_by(uin: params[:uin])
      if model_record.nil?
        Rails.logger.debug "No record found with UIN: #{params[:uin]}"
      else
        model_record.destroy
      Rails.logger.debug "Record with UIN #{params[:uin]} destroyed."
      end
      flash[:notice] = "Student record deleted. Class details saved separately."
    else
      flash[:alert] = "Student record with UIN #{params[:uin]} not found."
    end
    redirect_back(fallback_location: view_csv_path)
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

  def delete_all_csvs
    Dir[Rails.root.join("app/Charizard/util/public/output/*.csv")].each do |file|
      File.delete(file)
    end
    GraderBackup.delete_all
    GraderMatch.delete_all
    SeniorGraderBackup.delete_all
    SeniorGraderMatch.delete_all
    TaBackup.delete_all
    TaMatch.delete_all

    redirect_to view_csv_path, notice: "All CSV files and models have been deleted."
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

  def read_csv(file_path)
    csv_data = []
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
