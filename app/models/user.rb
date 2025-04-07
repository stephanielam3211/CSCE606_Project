# frozen_string_literal: true

class User < ApplicationRecord
    has_one :applicant, foreign_key: 'confirm'
    has_many :recommendations, foreign_key: "faculty_id"
    validates :email, presence: true, uniqueness: true

    ADMIN_EMAILS = [ "hz010627@tamu.edu", "aaron_xu92@tamu.edu", "yuvi@tamu.edu",
    "oifekoya0@tamu.edu", "neel27@tamu.edu", "carlislem@tamu.edu", "stephanie.lam_3211@tamu.edu" ]

    def self.from_google(auth)
        email = auth.info.email
      
        unless email.ends_with?("@tamu.edu")
          Rails.logger.info "Unauthorized login attempt with email: #{email}"
          return nil
        end
      
        user = find_or_initialize_by(email: email)
        profs_record = Course&.find_by(faculty_email: email)
      
        user.role = if ADMIN_EMAILS.include?(email) || Admin.exists?(email: email)
            "admin"
          elsif profs_record.present?
            "faculty"
          else
            "student"
          end

        user.name = auth.info.name
        user.email = email
        user.save!
        user
    end      
end
