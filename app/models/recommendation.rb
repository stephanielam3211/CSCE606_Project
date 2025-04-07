# frozen_string_literal: true

class Recommendation < ApplicationRecord
  after_initialize :set_default_admin, if: :new_record?

  private

  def set_default_admin
    self.admin ||= false
  end
    validates :email, presence: true
    validates :name, presence: true
    validates :selectionsTA, presence: true
    validates :course, presence: true
    validates :feedback, presence: true
end
