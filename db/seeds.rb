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