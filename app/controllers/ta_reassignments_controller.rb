# frozen_string_literal: true

class TaReassignmentsController < ApplicationController
    require "csv"
    def process_csvs
        apps_csv_path = Rails.root.join("app/Charizard/util/public/output", "Unassigned_Applicants.csv")
        needs_csv_path = Rails.root.join("app/Charizard/util/public/output", "New_Needs.csv")
        recommendation_path = Rails.root.join("tmp", "Prof_Prefs.csv")

        ta_csv_path = Rails.root.join("app/Charizard/util/public/output", "TA_Matches.csv")
        senior_grader_csv_path = Rails.root.join("app/Charizard/util/public/output", "Senior_Grader_Matches.csv")
        grader_csv_path = Rails.root.join("app/Charizard/util/public/output", "Grader_Matches.csv")

        [ ta_csv_path, senior_grader_csv_path, grader_csv_path ].each do |file|
          if File.exist?(file)
            tmp_file_path = Rails.root.join("tmp", File.basename(file))
            FileUtils.cp(file, tmp_file_path)
          end
        end

        python_path = `which python3`.strip  # Find Python path dynamically
        system("#{python_path} app/Charizard/main.py '#{apps_csv_path}' '#{needs_csv_path}' '#{recommendation_path}'")

        flash[:notice] = "CSV processing complete"

        combined_data = { ta: [], senior_grader: [], grader: [] }

        { ta: ta_csv_path, senior_grader: senior_grader_csv_path, grader: grader_csv_path }.each do |key, file|
          tmp_file_path = Rails.root.join("tmp", File.basename(file))
          if File.exist?(tmp_file_path)
            CSV.foreach(tmp_file_path, headers: true) do |row|
              combined_data[key] << row.to_h
            end
          end
        end
        
        # Append to the original CSV files while ensuring headers are written correctly
        { ta: ta_csv_path, senior_grader: senior_grader_csv_path, grader: grader_csv_path }.each do |key, file|
          if combined_data[key].any?
            # Check if the file exists and if it is empty or not
            write_headers = !File.exist?(file) || File.zero?(file)
            
            CSV.open(file, "a", write_headers: write_headers, headers: combined_data[key].first.keys) do |csv|
              combined_data[key].each do |row|
                csv << row.values
              end
            end
          end
        end

        File.delete(Rails.root.join("app/Charizard/util/public/output/New_Needs.csv"))
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

    def read_csv(file_path)
      csv_data = []
      CSV.foreach(file_path, headers: true) do |row|
        csv_data << row.to_h
      end
      csv_data
    end


end
