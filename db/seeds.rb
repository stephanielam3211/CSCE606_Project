# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
=begin
require 'csv'

csv_file = Rails.root.join('db', 'courses.csv')

CSV.foreach(csv_file, headers: true) do |row|
  Course.create!(
    course_name: row['course_name'],
    course_number: row['course_number'],
    section: row['section'],
    instructor: row['instructor'],
    faculty_email: row['faculty_email'],
    ta: row['ta'].to_i,
    senior_grader: row['senior_grader'].to_i,
    grader: row['grader'].to_i,
    pre_reqs: row['pre_reqs']&.strip.presence || ""
  )
end

puts "Seeded #{Course.count} courses"
=end

csv_file2 = Rails.root.join('db', 'TA_data.csv')

CSV.foreach(csv_file2, headers: true, col_sep: ",") do |row|
  timestamp = DateTime.strptime(row['Timestamp'], "%m/%d/%Y %H:%M") rescue nil
  Applicant.create!(
    timestamp: timestamp,
    email: row['Email Address'],
    name: row['First and Last Name'],
    uin: row['UIN'].to_i,
    number: row['Phone Number'],
    hours: row['How many hours do you plan to be enrolled in?'].to_i,
    degree: row['Degree Type?'],
    choice_1: row['1st Choice Course'].to_i,
    choice_2: row['2nd Choice Course'].to_i,
    choice_3: row['3rd Choice Course'].to_i,
    choice_4: row['4th Choice Course'].to_i,
    choice_5: row['5th Choice Course'].to_i,
    choice_6: row['6th Choice Course'].to_i,
    choice_7: row['7th Choice Course'].to_i,
    choice_8: row['8th Choice Course'].to_i,
    choice_9: row['9th Choice Course'].to_i,
    choice_10: row['10th Choice Course'].to_i,
    gpa: row['GPA'].to_f,
    citizenship: row['Country of Citizenship?'],
    cert: row['English language certification level?'].to_i,
    prev_course: row['Which courses have you taken at TAMU?'],
    prev_uni: row['Which courses have you taken at another university?'],
    prev_ta: row['Which courses have you TAd for?'],
    advisor: row['Who is your advisor (if applicable)?'],
    positions: row['What position are you applying for?']
  )
end


puts "Import complete!"
