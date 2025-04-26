# frozen_string_literal: true

class AddConfirmedToTaMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :ta_matches, :confirm, :boolean
  end
end
