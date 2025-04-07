# frozen_string_literal: true

class Applicant < ApplicationRecord
    belongs_to :user, foreign_key: 'confirm', optional: true

    validates :confirm, uniqueness: true
    has_many :recommendations

    validates :name, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :degree, presence: true
    validates :positions, presence: true
    validates :number, presence: true
    validates :uin, presence: true
    validates :hours, presence: true
    validates :citizenship, presence: true
    validates :cert, presence: true
    validate :min_course_choice

    def self.ransackable_attributes(auth_object = nil)
        super + [ "name", "email", "uin" ]
    end

    def self.ransackable_associations(auth_object = nil)
        []
    end

    private

    def min_course_choice
        course_choices = [
          choice_1, choice_2, choice_3, choice_4, choice_5,
          choice_6, choice_7, choice_8, choice_9, choice_10
        ]

        if course_choices.all?(&:blank?)
            errors.add(:base, "You must select at least one Course Choice.")
        end
    end
end
