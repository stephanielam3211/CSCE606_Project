class AddConfirmedToGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :grader_matches, :confirm, :boolean
  end
end
