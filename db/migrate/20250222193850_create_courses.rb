class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses do |t|
      t.string :course_name
      t.string :course_number
      t.string :section
      t.string :instructor
      t.string :faculty_email
      t.float :ta
      t.float :senior_grader
      t.float :grader
      t.text :pre_reqs

      t.timestamps
    end
  end
end
