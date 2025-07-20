# frozen_string_literal: true
namespace :import do
  desc "Import TA matches JSON"
  task ta_json: :environment do
    base_path = Rails.root.join("app", "Charizard", "util", "public", "output")
    file_path = base_path.join("TA_Matches.json")
    mapping = {
      "Course Number" => "course_number",
      "Section ID" => "section",
      "Instructor Name" => "ins_name",
      "Instructor Email" => "ins_email",
      "Student Name" => "stu_name",
      "Student Email" => "stu_email",
      "UIN" => "uin",
      "Calculated Score" => "score"
    }
    import_standard_json(file_path, TaMatch, mapping) if File.exist?(file_path)
  end

  desc "Import Senior Grader matches JSON"
  task senior_grader_json: :environment do
    base_path = Rails.root.join("app", "Charizard", "util", "public", "output")
    file_path = base_path.join("Senior_Grader_Matches.json")
    mapping = {
      "Course Number" => "course_number",
      "Section ID" => "section",
      "Instructor Name" => "ins_name",
      "Instructor Email" => "ins_email",
      "Student Name" => "stu_name",
      "Student Email" => "stu_email",
      "UIN" => "uin",
      "Calculated Score" => "score"
    }
    import_standard_json(file_path, SeniorGraderMatch, mapping) if File.exist?(file_path)
  end

  desc "Import Grader matches JSON"
  task grader_json: :environment do
    base_path = Rails.root.join("app", "Charizard", "util", "public", "output")
    file_path = base_path.join("Grader_Matches.json")
    mapping = {
      "Course Number" => "course_number",
      "Section ID" => "section",
      "Instructor Name" => "ins_name",
      "Instructor Email" => "ins_email",
      "Student Name" => "stu_name",
      "Student Email" => "stu_email",
      "UIN" => "uin",
      "Calculated Score" => "score"
    }
    import_standard_json(file_path, GraderMatch, mapping) if File.exist?(file_path)
  end
end

def import_standard_json(file_path, model, mapping)
  data = JSON.parse(File.read(file_path))
  puts "Importing records into #{model.name}"

  data.each do |row|
    mapped_row = row.transform_keys { |key| mapping[key] || key }
    filtered_row = mapped_row.slice(*model.column_names)

    if filtered_row["uin"] && model.exists?(uin: filtered_row["uin"])
      Rails.logger.debug "Skipping duplicate record for UIN: #{filtered_row['uin']}"
      next
    end

    model.create!(filtered_row)
  end
end
