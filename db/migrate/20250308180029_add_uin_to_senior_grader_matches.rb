# frozen_string_literal: true

class AddUinToSeniorGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :senior_grader_matches, :uin, :string
    add_index :senior_grader_matches, :uin, unique: true
  end
end
