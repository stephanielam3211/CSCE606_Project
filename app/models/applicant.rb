# frozen_string_literal: true

class Applicant < ApplicationRecord
    has_many :recommendations
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
end
