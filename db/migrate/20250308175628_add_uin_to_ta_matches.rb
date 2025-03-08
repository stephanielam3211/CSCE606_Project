# frozen_string_literal: true

class AddUinToTaMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :ta_matches, :uin, :string
    add_index :ta_matches, :uin, unique: true
  end
end
