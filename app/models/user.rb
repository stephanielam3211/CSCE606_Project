# frozen_string_literal: true

class User < ApplicationRecord
    has_many :recommendations, foreign_key: "faculty_id"

    validates :email, presence: true, uniqueness: true

    def self.from_google(auth)
        where(email: auth.info.email).first_or_initialize do |user|
            user.name = auth.info.name
            user.email = auth.info.email
            user.save
        end
    end
end
