# frozen_string_literal: true

class User < ApplicationRecord
    has_many :recommendations, foreign_key: "faculty_id"

    validates :email, presence: true, uniqueness: true

    def self.from_google(auth)
        email = auth.info.email

        unless email.ends_with?("@tamu.edu")
            Rails.logger.info "Unauthorized login attemp with email: #{email}"
            return nil
        end

        where(email: email).first_or_initialize do |user|
            user.name = auth.info.name
            user.email = email
            user.save
        end
    end
end
