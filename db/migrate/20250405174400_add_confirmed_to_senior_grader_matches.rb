class AddConfirmedToSeniorGraderMatches < ActiveRecord::Migration[7.2]
  def change
    add_column :senior_grader_matches, :confirm, :boolean
  end
end
