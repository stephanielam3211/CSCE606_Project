# frozen_string_literal: true

class TaReassignmentsController < ApplicationController
    require "csv"
    def process_csvs
      if params[:file3].present?
        apps_csv_path = Rails.root.join("app/Charizard/util/public/output", "Unassigned_Applicants.csv")
        needs_csv_path = Rails.root.join("app/Charizard/util/public/output", "New_Needs.csv")

        file3_path = save_uploaded_file(params[:file3])

        unless File.exist?(apps_csv_path) && File.exist?(needs_csv_path)
          flash[:alert] = "One or more required CSV files are missing."
          return redirect_to ta_reassignments_new_path
        end

        [ "Grader_Matches.csv", "Senior_Grader_Matches.csv", "TA_Matches.csv" ].each do |file|
          system("mv #{file} #{file}_o.csv") if File.exist?(file)
        end

        python_path = `which python3`.strip  # Find Python path dynamically
        system("#{python_path} app/Charizard/main.py '#{apps_csv_path}' '#{needs_csv_path}' '#{file3_path}'")

        flash[:notice] = "CSV processing complete"
        redirect_to view_csv_path
      else
        flash[:alert] = "An error has occurred."
        redirect_to ta_reassignments_new_path
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
    def download_csv
      file_name = params[:file]
      file_path = Rails.root.join("app", "Charizard", "output", file_name)
      if File.exist?(file_path)
        send_file file_path, filename: file_name, type: "text/csv", disposition: "attachment"
      else
        redirect_to root_path, alert: "File not found."
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
end
