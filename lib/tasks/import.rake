namespace :import do
  desc "Import CSV files into the database"
  task csv: :environment do
    require 'csv'

    csv_mappings = {
      'TA_Matches.csv' => TaMatch,
      'TA_Backups.csv' => TaBackup,
      'Grader_Matches.csv' => GraderMatch,
      'Grader_Backups.csv' => GraderBackup,
      'Senior_Grader_Backups.csv' => SeniorGraderBackup,
      'Senior_Grader_Matches.csv' => SeniorGraderMatch
    }

    header_mapping = {
      'Course Number' => 'course_number',
      'Section ID' => 'section',
      'Instructor Name' => 'ins_name',
      'Instructor Email' => 'ins_email',
      'Student Name' => 'stu_name',
      'Student Email' => 'stu_email',
      'Calculated Score' => 'score'
    }

    csv_mappings.each do |file_name, model|
      file_path = Rails.root.join('app', 'Charizard', 'util','public','output',file_name )

      if File.exist?(file_path)
        model.destroy_all
        puts "Importing #{file_name} into #{model.table_name}..."
        
        CSV.foreach(file_path, headers: true) do |row|
          mapped_row = row.to_h.transform_keys { |key| header_mapping[key] || key }
          model.create(mapped_row)
        end
        
        puts "#{file_name} imported successfully!"
      else
        puts "File #{file_name} not found, skipping..."
      end
    end
  end
end