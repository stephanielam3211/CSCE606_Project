# frozen_string_literal: true

class AddGpaToApplicants < ActiveRecord::Migration[7.2]
  def change
    add_column :applicants, :gpa, :float
  end
end
