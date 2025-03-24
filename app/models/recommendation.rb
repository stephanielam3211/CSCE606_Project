# frozen_string_literal: true

class Recommendation < ApplicationRecord
    validates :email, presence: true
    validates :name, presence: true
    validates :selectionsTA, presence: true
    validates :course, presence: true
    validates :feedback, presence: true
end
