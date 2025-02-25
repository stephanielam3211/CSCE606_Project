class CreateBlacklists < ActiveRecord::Migration[7.2]
  def change
    create_table :blacklists do |t|
      t.string :student_name
      t.string :student_email

      t.timestamps
    end
  end
end
