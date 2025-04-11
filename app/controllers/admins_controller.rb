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
      redirect_to root_path, notice: 'All data has been cleared.'
    end

    def export
      data = {
        applicants: Applicant.all,
        withdrawal_requests: WithdrawalRequest.all,
        courses: Course.all,
        blacklist: Blacklist.all,
        admins: Admin.all,
        users: User.all,
        recommendations: Recommendation.all
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
    
        Dir[output_folder_path.join("**", "*")].each do |file|
          next if File.directory?(file)
    
          entry_name = Pathname.new(file).relative_path_from(output_folder_path).to_s
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
      elsif table_name == :applicants
        applicant_headers = [
          "Timestamp", "Email Address", "First and Last Name", "UIN", "Phone Number", "How many hours do you plan to be enrolled in?", 
          "Degree Type?", "1st Choice Course", "2nd Choice Course", "3rd Choice Course", "4th Choice Course", "5th Choice Course", 
          "6th Choice Course", "7th Choice Course", "8th Choice Course", "9th Choice Course", "10th Choice Course", "GPA", 
          "Country of Citizenship?", "English language certification level?", "Which courses have you taken at TAMU?", 
          "Which courses have you taken at another university?", "Which courses have you TAd for?", "Who is your advisor (if applicable)?", 
          "What position are you applying for?"
        ]
        CSV.generate(headers: true) do |csv|
          csv << applicant_headers
          records.each do |record|
            csv << [
              record.timestamp,
              record.email,
              record.name,
              record.uin,
              record.number,
              record.hours,
              record.degree,
              record.choice_1,
              record.choice_2,
              record.choice_3,
              record.choice_4,
              record.choice_5,
              record.choice_6,
              record.choice_7,
              record.choice_8,
              record.choice_9,
              record.choice_10,
              record.gpa,
              record.citizenship,
              record.cert,
              record.prev_course,
              record.prev_uni,
              record.prev_ta,
              record.advisor,
              record.positions
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
      return redirect_to(root_path, alert: "No file uploaded") unless uploaded_file

      Zip::File.open(uploaded_file.path) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name.ends_with?('.csv')
    
          table_name = File.basename(entry.name, ".csv").downcase.to_sym
          csv_content = entry.get_input_stream.read
    
          case table_name
          when :courses
            import_courses(csv_content)
          when :applicants
            import_applicants(csv_content)
          when :Modified_assignments
            save_csv_to_file(table_name, csv_content)
          when :New_Needs
            save_csv_to_file(table_name, csv_content)
          when :Assignments
            save_csv_to_file(table_name, csv_content)
          else
            import_generic(table_name, csv_content)
          end
        end
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
        Applicant.create!(
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

      model.delete_all
    
      CSV.parse(csv_data, headers: true) do |row|
        model.create!(row.to_hash)
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
