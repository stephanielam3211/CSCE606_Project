# frozen_string_literal: true

namespace :import do
  desc "Import CSV files into the database"
  task csv: :environment do
    require "csv"

    csv_mappings = {
      "TA_Matches.csv" => TaMatch,
      "Grader_Matches.csv" => GraderMatch,
      "Senior_Grader_Matches.csv" => SeniorGraderMatch,
      "Unassigned_Applicants.csv" => UnassignedApplicant
    }

    ta_header_mapping = {
      "Course Number" => "course_number",
      "Section ID" => "section",
      "Instructor Name" => "ins_name",
      "Instructor Email" => "ins_email",
      "Student Name" => "stu_name",
      "Student Email" => "stu_email",
      "UIN"=> "uin",
      "Calculated Score" => "score"
    }

    unassigned_applicants_mapping = {
      "timestamp" => "timestamp",
      "email address" => "email",
      "first and last name" => "name",
      "uin" => "uin",
      "phone number" => "number",
      "how many hours do you plan to be enrolled in?" => "hours",
      "degree type?" => "degree",
      "1st choice course" => "choice_1",
      "2nd choice course" => "choice_2",
      "3rd choice course" => "choice_3",
      "4th choice course" => "choice_4",
      "5th choice course" => "choice_5",
      "6th choice course" => "choice_6",
      "7th choice course" => "choice_7",
      "8th choice course" => "choice_8",
      "9th choice course" => "choice_9",
      "10th choice course" => "choice_10",
      "gpa" => "gpa",
      "country of citizenship?" => "citizenship",
      "english language certification level?" => "cert",
      "which courses have you taken at tamu?" => "prev_course",
      "which courses have you taken at another university?" => "prev_uni",
      "which courses have you tad for?" => "prev_ta",
      "who is your advisor (if applicable)?" => "advisor",
      "what position are you applying for?" => "positions"
    }

    csv_mappings.each do |file_name, model|
      file_path = Rails.root.join("app", "Charizard", "util", "public", "output", file_name)

      if File.exist?(file_path)
        model.destroy_all
        puts "Importing #{file_name} into #{model.table_name}..."

        if file_name == "Unassigned_Applicants.csv"  
          Rails.logger.debug "Processing #{file_name}..."

          CSV.foreach(file_path, headers: true) do |row|
            raw_row = row.to_h
            mapped_row = {}
            raw_row.each do |key, value|
              normalized_key = key.strip.downcase
              model_key = unassigned_applicants_mapping[normalized_key]
        
              if model_key
                mapped_row[model_key] = value
              else
                Rails.logger.debug "Unmapped key: #{key} => Skipping"
              end
            end
            filtered_row = mapped_row.slice(*model.column_names)


            existing = model.where(email: filtered_row["email"]).or(model.where(uin: filtered_row["uin"])).first
            if existing
              Rails.logger.debug "Skipping duplicate for email: #{filtered_row['email']} or UIN: #{filtered_row['uin']}"
              puts "Skipping #{filtered_row['uin']} import"
              next
            end
            model.create!(filtered_row)
          end
        else
          CSV.foreach(file_path, headers: true) do |row|
            mapped_row = row.to_h.transform_keys { |key| ta_header_mapping[key] || key }
            filtered_row = mapped_row.slice(*model.column_names)

            if filtered_row["uin"] && model.exists?(uin: filtered_row["uin"])
              Rails.logger.debug "Skipping duplicate record for UIN: #{filtered_row['uin']}"
              puts "Skipping #{filtered_row['uin']} import"
              next
            end

            model.create(mapped_row)
          end
        end
        puts "#{file_name} imported successfully!"
      else
        puts "File #{file_name} not found, skipping..."
      end
    end
  end
end
