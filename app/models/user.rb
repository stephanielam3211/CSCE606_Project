# frozen_string_literal: true

class User < ApplicationRecord
    has_many :recommendations, foreign_key: "faculty_id"

    validates :email, presence: true, uniqueness: true

    ADMIN_EMAILS = [ "hz010627@tamu.edu", "aaron_xu92@tamu.edu", "yuvi@tamu.edu",
    "oifekoya0@tamu.edu", "neel27@tamu.edu", "carlislem@tamu.edu", "stephanie.lam_3211@tamu.edu" ]

    def self.from_google(auth)
        email = auth.info.email

        unless email.ends_with?("@tamu.edu")
            Rails.logger.info "Unauthorized login attemp with email: #{email}"
            return nil
        end

        where(email: email).first_or_initialize do |user|
            profs_class = Course
            profs_record = profs_class&.find_by(faculty_email: email)

            role = if ADMIN_EMAILS.include?(email)
                     "admin"
            elsif profs_record.nil?
                     "student"
            else
                     "faculty"
            end

            user.name = auth.info.name
            user.email = email
            user.role = role
            user.save
        end
    end
end
