# frozen_string_literal: true

class User < ApplicationRecord
    has_one :applicant, foreign_key: "confirm"
    has_many :recommendations, foreign_key: "faculty_id"
    validates :email, presence: true, uniqueness: true

    ADMIN_EMAILS = (ENV["ADMIN_EMAILS"] || "").split(",").map(&:strip)

    def self.from_google(auth)
        email = auth.info.email

        unless email.ends_with?("@tamu.edu")
          Rails.logger.info "Unauthorized login attempt with email: #{email}"
          return nil
        end

        user = find_or_initialize_by(email: email)
        profs_record = Advisor&.find_by(email: email)

        user.role = if ADMIN_EMAILS.include?(email) || Admin.exists?(email: email)
            "admin"
        elsif profs_record.present?
            "faculty"
        else
            "student"
        end

        Admin.create(email: email) if user.role == "admin" && !Admin.exists?(email: email)

        user.name = auth.info.name
        user.email = email
        user.save!
        user
    end
end
