# frozen_string_literal: true

class CreateWithdrawalRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :withdrawal_requests do |t|
      t.string :course_number
      t.string :section_id
      t.string :instructor_name
      t.string :instructor_email
      t.string :student_name
      t.string :student_email

      t.timestamps
    end
  end
end
