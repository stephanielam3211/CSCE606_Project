# frozen_string_literal: true

class RecordsController < ApplicationController
  def index
    @table_name = params[:table]
    case @table_name
    when "grader_matches"
      @records = GraderMatch.all
    when "recommendations"
      @records = Recommendation.all
    when "senior_grader_matches"
      @records = SeniorGraderMatch.all
    when "ta_matches"
      @records = TaMatch.all
    else
      @records = []
    end
    @records = @records.sort_by { |r| r.confirm ? 0 : 1 } if @records.present?
  end

  def toggle_assignment
    model = params[:table].classify.constantize
    record = model.find(params[:id])
    record.update(assigned: !record.assigned)
    redirect_back fallback_location: root_path
  end

  def revoke_assignment
    model = params[:table].classify.constantize
    record = model.find(params[:id])
    #record.update(confirm: false)
    record.assigned = false
    record.confirm = false
    record.save!
    redirect_back(fallback_location: request.referer || root_path)
  end

  def mass_confirm
    model = params[:table].classify.constantize
    model.find_each{ |record|
      record.update(confirm: false)
    }
    redirect_back(fallback_location: request.referer || root_path)
  end

  def mass_toggle_assignment
    model = params[:table].classify.constantize
    if model.where(assigned: true).exists?
      model.find_each{ |record|
      record.update(assigned: false)
      }
      notice = "All assignments have been unsent."
    else
      model.find_each{ |record|
      record.update(assigned: true)
      }
      notice = "All assignments have been sent."
    end
    redirect_back(fallback_location: request.referer || root_path)
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

    headers = records.first.keys

      # Add removed records to Modified_assignments
      CSV.open(modified_csv, "a", headers: headers, write_headers: !File.exist?(modified_csv)) do |csv|
        uins.each do |uin|
          model_record = model_class.find_by(uin: uin)
          next unless model_record
      
          # Convert to string-keyed hash and rename keys to match CSV headers
          row_data = {
            "Course Number" => model_record.course_number,
            "Section ID" => model_record.section,
            "Instructor Name" => model_record.ins_name,
            "Instructor Email" => model_record.ins_email,
            "Student Name" => model_record.stu_name,
            "Student Email" => model_record.stu_email,
            "UIN" => model_record.uin.to_s,
            "Calculated Score" => model_record.score
          }
      
          csv << headers.map { |h| row_data[h] }
        end
      end
    # Update original CSV (remove unconfirmed)
    records.reject! { |r| uins.include?(r["UIN"]) }  
    CSV.open(file_path, "w", headers: records.first&.keys || [], write_headers: true) do |csv|
      records.each { |r| csv << r.values }
    end  
    # Add removed to Modified_assignments
    # CSV.open(modified_csv, "a", headers: records.first&.keys || [], write_headers: !File.exist?(modified_csv)) do |csv|
    #   uins.each do |uin|
    #     record = uin_to_record_map[uin]
    #     csv << record.values if record
    #   end
    # end  

    
      uins.each do |uin|
        model_record = model_class.find_by(uin: uin)
        next unless model_record

        # Add to Unassigned_Applicants.csv
        applicant = Applicant.find_by(uin: uin)
        if applicant
          UnassignedApplicant.create(applicant.attributes.except("id", "created_at", "updated_at","confirm"))
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
            if applicant.present? && applicant.respond_to?(:attributes)
              # Create the row based on the direct mapping
              row_values = applicant_headers.map do |header|
                attribute = direct_mapping[header]  # Get the model attribute for this header
                applicant.send(attribute) || ""  # Use the value from the model, or fallback to an empty string if nil
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
          feedback: "I do not want to work with this student",
          additionalfeedback: "Auto Generated by Admin for Algorithm",
          admin: true
        )

      end
      model_class.where(uin: uins).destroy_all

      flash[:notice] = "All unconfirmed assignments were deleted and processed."
      redirect_back fallback_location: view_csv_path
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
      feedback: "I do not want to work with this student",
      additionalfeedback: "Auto Generated by Admin for Algorithm",
      admin: true
    )
    if params[:deny].present?
      logger.debug "Params received: #{params.inspect}"
      withdrawal_request = WithdrawalRequest.create(
        student_email: params[:stu_email],
        student_name: params[:stu_name],
        course_number: params[:course_number],
        section_id: params[:section_id],
        instructor_email: params[:ins_email],
        instructor_name: params[:ins_name]
      )
      if withdrawal_request.persisted?
        flash[:notice] = "TA assignment deleted and withdrawal request created."
      else
        flash[:alert] = "TA assignment deleted, but unable to create withdrawal request."
      end
    end

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
        UnassignedApplicant.create(model_record1.attributes.except("id", "created_at", "updated_at","confirm"))
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
      if model_record.destroy
        respond_to do |format|
          format.js   
          format.html { redirect_to all_records_path(table: 'ta_matches')}
  
        end
      Rails.logger.debug "Record with UIN #{params[:uin]} destroyed."
      flash[:notice] = "Student record deleted. Class details saved separately."
      end
    else
      flash[:alert] = "Student record with UIN #{params[:uin]} not found."
    end
  end

  def determine_assignment_type(record)
    case record
    when "TA_Matches.csv" then "TA"
    when "Senior_Grader_Matches.csv" then "Senior_Grader"
    when "Grader_Matches.csv" then "Grader"
    end
  end

end
