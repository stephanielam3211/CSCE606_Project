# frozen_string_literal: true

class CreateSeniorGraderMatches < ActiveRecord::Migration[7.2]
  def change
    create_table :senior_grader_matches do |t|
      t.string :course_number
      t.string :section
      t.string :ins_name
      t.string :ins_email
      t.string :stu_name
      t.string :stu_email
      t.integer :score

      t.timestamps
    end
  end
end
