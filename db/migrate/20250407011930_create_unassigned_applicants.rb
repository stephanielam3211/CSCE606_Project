# frozen_string_literal: true

class CreateUnassignedApplicants < ActiveRecord::Migration[7.2]
    def change
      create_table :unassigned_applicants do |t|
        t.string  :email
        t.string  :name
        t.string  :degree
        t.string  :positions
        t.text    :number
        t.integer :uin
        t.integer :hours
        t.string  :citizenship
        t.integer :cert
        t.text    :prev_course
        t.text    :prev_uni
        t.text    :prev_ta
        t.string  :advisor
        t.integer :choice_1
        t.integer :choice_2
        t.integer :choice_3
        t.integer :choice_4
        t.integer :choice_5
        t.integer :choice_6
        t.integer :choice_7
        t.integer :choice_8
        t.integer :choice_9
        t.integer :choice_10
        t.time    :timestamp
        t.float   :gpa
        t.timestamps
      end
  end
end
