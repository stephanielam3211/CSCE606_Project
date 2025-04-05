class AddAssignedToGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :grader_matches, :assigned, :boolean
  end
end
