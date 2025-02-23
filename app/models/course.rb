class Course < ApplicationRecord
    validates :course_name, :course_number, :section, :instructor, presence: true
  validates :faculty_email, uniqueness: false, format: { with: URI::MailTo::EMAIL_REGEXP }
  def self.ransackable_attributes(auth_object = nil)
    super + ["course_name", "course_number", "section", "instructor"]
end
def self.ransackable_associations(auth_object = nil)
    []
end
end
