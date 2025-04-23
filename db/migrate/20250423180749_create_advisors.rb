class CreateAdvisors < ActiveRecord::Migration[7.2]
  def change
    create_table :advisors do |t|
      t.string :name
      t.text :email

      t.timestamps
    end
    add_index :advisors, :email, unique: true
  end
end
