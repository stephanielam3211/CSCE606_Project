# frozen_string_literal: true

class SeniorGraderMatch < ApplicationRecord
    after_initialize :set_default_confirm, if: :new_record?

  private

  def set_default_confirm
    self.confirm ||= false
  end
end
