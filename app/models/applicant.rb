# frozen_string_literal: true

class Applicant < ApplicationRecord
  belongs_to :user, foreign_key: "confirm", optional: true
  before_validation :ensure_timestamp

  validates :confirm, uniqueness: true
  has_many :recommendations

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :degree, presence: true
  validates :positions, presence: true
  validates :number, presence: true, format: { with: /\A\+?[0-9\-]{10,15}\z/, message: "must be a valid phone number" }
  validates :uin, presence: true,format: {
              with: /\A\d{9}\z/,
              message: "must be exactly 9 digits"
            }
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 16.0 }
  validates :citizenship, presence: true
  validates :cert, presence: true
  validates :gpa, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 4.0 }
  validate :min_course_choice
  validates :prev_course, length: { maximum: 200, too_long: "%{count} characters is the maximum allowed" },
            format: { 
              with: /\A\d{3}(,\d{3})*\z/,
              message: "Must Only Include Course Numbers\ '123,345,456'"
            }
  validate :check_duplicates
  validates :prev_uni, length: { maximum: 200, too_long: "%{count} characters is the maximum allowed" }
  validates :prev_ta, length: { maximum: 200, too_long: "%{count} characters is the maximum allowed" },
            format: { 
              with: /\A\d{3}(,\d{3})*\z/,
              message: "Must Only Include Course Numbers Numbers\ '123,345,456'"
            }
  # type casting
  ransacker :uin do |parent|
    Arel.sql("CAST(#{parent.table.name}.uin AS TEXT)")
  end

  def self.ransackable_attributes(auth_object = nil)
    super + [ "name", "email", "uin_text" ]
  end

  def uin_text
    uin.to_s
  end

  ransacker :uin_text do
    Arel.sql("CAST(uin AS TEXT)")
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def check_duplicates
    return if prev_course.blank? || prev_ta.blank?
    
    prev_numbers = prev_course.split(",")
    prev_ta_numbers = prev_ta.split(",")

    if prev_numbers.uniq.length != prev_numbers.length
      errors.add(:prev_course, "must not contain duplicate course numbers")
    end
    if prev_ta_numbers.uniq.length != prev_ta_numbers.length
      errors.add(:prev_ta, "must not contain duplicate course numbers")
    end
  end

  private
  def ensure_timestamp
    self.timestamp ||= Time.current
  end

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
