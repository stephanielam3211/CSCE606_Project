# frozen_string_literal: true

class TaMatch < ApplicationRecord
    after_initialize :set_default_confirm, if: :new_record?

  private

  def set_default_confirm
    self.confirm ||= false
  end
end
