class CreateAssignments < ActiveRecord::Migration[7.2]
  def change
    create_table :assignments do |t|
      t.references :applicant, null: false, foreign_key: true
      t.string :course_id
      t.integer :weighting_score

      t.timestamps
    end
  end
end
