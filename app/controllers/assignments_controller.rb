require 'csv'

class AssignmentsController < ApplicationController
# Call to get assignments
  def index
# Call to fetch data
#  @assignements = Assignment.all
  end 

  def import_csv
    file = params[:file]
    if file.blank?
      flash[:alert] = "Please select CSV file to upload"
	return redirect_to assignments_path
   end
  
   begin
     choice_columns = [
  "1st Choice Course",
  "2nd Choice Course",
  "3rd Choice Course",
  "4th Choice Course",
  "5th Choice Course",
  "6th Choice Course",
  "7th Choice Course",
  "8th Choice Course",
  "9th Choice Course",
  "10th Choice Course"
]
   row_count = 0
   CSV.foreach(file.path, headers: true) do |row|
     row_count +=1
     Rails.logger.info "Process row#{row_count} with UIN #{row['UIN']}"  
 # Assign the applicants
   applicant = Applicant.find_or_initialize_by(uin: row["UIN"])
   applicant.course_choice = choice_columns.map do |col|
      row[col].presence
   end.compact
  
   applicant.name            = row["First and Last Name"]
   applicant.degree_type     = row["Degree Type?"]
   applicant.gpa             = row["GPA"].to_f
   applicant.email_address   = row["Email Address"]
   applicant.phone_number    = row["Phone Number"]
   applicant.hours           = row["How many hours do you plan to be enrolled in"]
   applicant.language        = row["English language certification level?"]
   applicant.country         = row["Country of Citizenship?"]
   applicant.position        = row["What position are you applying for?"]
   applicant.advisor         = row["Who is your advisor (if applicable)?"]
   applicant.cources         = row["Which courses have you taken at TAMU?"]
   
   applicant.save!
  
   score = compute_weighting(row)

# Record score

   assignment = Assignment.find_or_initialize_by(applicant: applicant, course_id: row["1st Choice Course"])
   assignment.weighting_score = score

   assignment.save!
  end
   Rails.logger.info "Done processing #{row_count} rows"
   flash[:notice] = "CSV imported successfully! Finished Processing #{row_count} rows."
   redirect_to assignments_path
 
 rescue => e
    flash[:alert] = "Error while importing CSV"
   redirect_to assignments_path
  end
 end
 
# Clarifying Weighted method

  private 
def compute_weighting(row)
      score = 0
# Give bonus to PHD
# Give bonus to previous TAs
# Give bonus to higher GPA

# check if student has PHD
    if row["Degree Type?"]&.downcase =="phd"
      score += 50
  end

# Check if applicant has been a TAMU TA
    if row["Which courses have you TAd for?"]&.include?(row["1st Choice Course"])
      score +=30
  end

# bonus for GPA higher than 3.5
    if row["GPA"].to_f >= 3.5
      score += 10
  end

# Subtract points depending on english level cert... level three or higher
     if row["English language certification level?"]&.match?(/level\s+3/i)
       score -= 5
  end

  score
 end
end
