# frozen_string_literal: true

class AddAssignedToTaMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :ta_matches, :assigned, :boolean
  end
end
