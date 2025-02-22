class Course < ApplicationRecord
    validates :course_name, :course_number, :section, :instructor, presence: true
  validates :faculty_email, uniqueness: false, format: { with: URI::MailTo::EMAIL_REGEXP }
end
