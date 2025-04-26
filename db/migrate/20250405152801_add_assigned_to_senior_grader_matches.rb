# frozen_string_literal: true

class AddAssignedToSeniorGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :senior_grader_matches, :assigned, :boolean
  end
end
