# frozen_string_literal: true

class AddConfirmToApplicants < ActiveRecord::Migration[7.2]
  def change
    add_column :applicants, :confirm, :integer, default: 0, null: false
  end
end
