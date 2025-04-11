class AdminsController < ApplicationController
    
    require 'zip'
    before_action :require_admin
  
    def new
    end

    def clear(skip_redirect: false)
      Admin.where.not(email: ["carlislem@tamu.edu", 'yuvi@tamu.edu']).delete_all
      User.delete_all
      GraderMatch.delete_all
      SeniorGraderMatch.delete_all
      TaMatch.delete_all
      WithdrawalRequest.delete_all
      Course.delete_all
      Applicant.delete_all
      Blacklist.delete_all
      Recommendation.delete_all
      Dir[Rails.root.join("app/Charizard/util/public/output/*.csv")].each do |file|
        File.delete(file)
      File.delete(Rails.root.join("tmp", "TA_Matches.csv")) if File.exist?(Rails.root.join("tmp", "TA_Matches.csv"))
      File.delete(Rails.root.join("tmp", "Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Grader_Matches.csv"))
      File.delete(Rails.root.join("tmp", "Senior_Grader_Matches.csv")) if File.exist?(Rails.root.join("tmp", "Senior_Grader_Matches.csv"))
      end
      unless skip_redirect
        redirect_to root_path, notice: 'All data has been cleared.'
        return
      end
    end

    def export
      data = {
        applicants: Applicant.all,
        withdrawal_requests: WithdrawalRequest.all,
        courses: Course.all,
        blacklist: Blacklist.all,
        users: User.all,
        recommendations: Recommendation.all,
        unassigned_applicants: UnassignedApplicant.all,
        ta_matches: TaMatch.all,
        senior_grader_matches: SeniorGraderMatch.all,
        grader_matches: GraderMatch.all,
      }
    
      output_folder_path = Rails.root.join("app", "Charizard", "util", "public", "output")
      buffer = StringIO.new
    
      Zip::OutputStream.write_buffer(buffer) {} 
      buffer.rewind
    
      Zip::File.open_buffer(buffer) do |zip|
        data.each do |table_name, records|
          csv_data = generate_table_csv(table_name, records)
          zip.get_output_stream("#{table_name}.csv") { |f| f.write(csv_data) }
        end
    
        skip_files = ["Unassigned_Applicants.csv", "TA_Matches.csv", "Grader_Matches.csv", "Senior_Grader_Matches.csv"] # Add any files you want to skip

        Dir[output_folder_path.join("**", "*")].each do |file|
          next if File.directory?(file)
          entry_name = Pathname.new(file).relative_path_from(output_folder_path).to_s
          
          next if skip_files.include?(File.basename(file))
          zip.add(entry_name, file) unless zip.find_entry(entry_name)
        end
      end
    
      buffer.rewind
      send_data buffer.read, type: 'application/zip', filename: "Data_Export_(#{Date.today}).zip"
    end


    def generate_table_csv(table_name, records)
      Rails.logger.debug "table name: #{table_name}"
      table_name.to_s.strip.downcase
      Rails.logger.debug "table name: #{table_name}"
      Rails.logger.debug "table_name.inspect: #{table_name.inspect}"

      if table_name == :courses
        course_headers = [
          "Course_Name", "Course_Number", "Section", "Instructor", "Faculty_Email", "TA?", 
          "Senior_Grader", "Grader", "Professor Pre-Reqs"
        ]
        CSV.generate(headers: true) do |csv|
          csv << course_headers
          records.each do |record|
            csv << [
              record.course_name,
              record.course_number,
              record.section,
              record.instructor,
              record.faculty_email,
              record.ta,
              record.senior_grader,
              record.grader,
              record.pre_reqs
            ]
          end
        end
      else
        CSV.generate(headers: true) do |csv|
          if records.any?
            csv << records.first.attributes.keys
            records.each { |record| csv << record.attributes.values }
          else
            csv << ["No records for #{table_name}"]
          end
        end
      end
    end


    def import
      clear(skip_redirect: true)
    
      uploaded_file = params[:file]
      unless uploaded_file
        redirect_to(root_path, alert: "No file uploaded")
        return
      end
    
      begin
        Zip::File.open(uploaded_file.path) do |zip_file|
          zip_file.each do |entry|
            next unless entry.name.ends_with?('.csv')
    
            table_name = File.basename(entry.name, ".csv").downcase.to_sym
            csv_content = entry.get_input_stream.read
    
            case table_name
            when :courses
              import_courses(csv_content)
            when :modified_assignments, :new_needs, :assignments
              save_csv_to_file(table_name, csv_content)
            when :unassigned_applicants
              import_applicants(csv_content)
            when :new_needs 
              save_csv_to_file(table_name, csv_content)
            else
              import_generic(table_name, csv_content)
            end
          end
        end
      rescue => e
        Rails.logger.error("Import failed: #{e.message}")
        redirect_to root_path, alert: "Import failed: #{e.message}"
        return
      end
    
      redirect_to root_path, notice: "Import completed successfully."
    end

    def save_csv_to_file(table_name, csv_content)
      output_path = Rails.root.join("app", "Charizard", "util", "public", "output")
      FileUtils.mkdir_p(output_path)
    
      file_path = output_path.join("#{table_name}.csv")
      File.write(file_path, csv_content)
    end


    def import_courses(csv_data)
      CSV.parse(csv_data, headers: true) do |row|
        Course.create!(
          course_name: row["Course_Name"],
          course_number: row["Course_Number"],
          section: row["Section"],
          instructor: row["Instructor"],
          faculty_email: row["Faculty_Email"],
          ta: row["TA?"],
          senior_grader: row["Senior_Grader"],
          grader: row["Grader"],
          pre_reqs: row["Professor Pre-Reqs"]
        )
      end
    end

    def import_applicants(csv_data)
      CSV.parse(csv_data, headers: true) do |row|
        UnassignedApplicant.create!(
          timestamp: row["Timestamp"],
          email: row["Email Address"],
          name: row["First and Last Name"],
          uin: row["UIN"],
          number: row["Phone Number"],
          hours: row["How many hours do you plan to be enrolled in?"],
          degree: row["Degree Type?"],
          choice_1: row["1st Choice Course"],
          choice_2: row["2nd Choice Course"],
          choice_3: row["3rd Choice Course"],
          choice_4: row["4th Choice Course"],
          choice_5: row["5th Choice Course"],
          choice_6: row["6th Choice Course"],
          choice_7: row["7th Choice Course"],
          choice_8: row["8th Choice Course"],
          choice_9: row["9th Choice Course"],
          choice_10: row["10th Choice Course"],
          gpa: row["GPA"],
          citizenship: row["Country of Citizenship?"],
          cert: row["English language certification level?"],
          prev_course: row["Which courses have you taken at TAMU?"],
          prev_uni: row["Which courses have you taken at another university?"],
          prev_ta: row["Which courses have you TAd for?"],
          advisor: row["Who is your advisor (if applicable)?"],
          positions: row["What position are you applying for?"]
        )
      end
    end
    def import_generic(table_name, csv_data)
      model = table_name.to_s.classify.safe_constantize
      return unless model
    
      CSV.parse(csv_data, headers: true) do |row|
        model.create!(row.to_hash)
      end
      if [TaMatch, SeniorGraderMatch, GraderMatch].include?(model)
        Rails.logger.debug "model: #{model}"
        Rails.logger.debug "csv_data: #{csv_data}"
    
        records = model.all
    
        filename =
          case model.name
          when "TaMatch"
            "TA_Matches.csv"
          when "GraderMatch"
            "Grader_Matches.csv"
          when "SeniorGraderMatch"
            "Senior_Grader_Matches.csv"
          else
            "Matches.csv"
          end
    
        output_path = Rails.root.join("app", "Charizard", "util", "public", "output", filename)
    
        CSV.open(output_path, "w", write_headers: true, headers: [
          "Course Number", "Section ID", "Instructor Name", "Instructor Email",
           "Student Name", "Student Email", "UIN", "Calculated Score"
           ]) do |csv|
          records.each do |record|
            csv << [
              record.course_number,
              record.section,
              record.ins_name,
              record.ins_email,
              record.stu_name,
              record.stu_email,
              record.uin,
              record.score
            ]
          end
        end
      end
    end
  
    def create
      email = params[:email]&.strip&.downcase
  
      if Admin.exists?(email: email)
        flash[:alert] = "#{email} is already an admin."
      else
        Admin.create!(email: email)
        flash[:notice] = "#{email} has been added as an admin!"
      end
  
      redirect_to new_admin_path
    end
  
    def require_admin
      unless session[:role] == "admin"
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
