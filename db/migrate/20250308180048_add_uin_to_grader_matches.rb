# frozen_string_literal: true

class AddUinToGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :grader_matches, :uin, :string
    add_index :grader_matches, :uin, unique: true
  end
end
