# frozen_string_literal: true

class Applicant < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true,
format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :degree, presence: true
    validates :positions, presence: true
    validates :number, presence: true
    validates :uin, presence: true
    validates :hours, presence: true
    validates :citizenship, presence: true
    validates :cert, presence: true
    def self.ransackable_attributes(auth_object = nil)
        super + ["name", "email", "uin"]
    end
    def self.ransackable_associations(auth_object = nil)
        []
    end
end
