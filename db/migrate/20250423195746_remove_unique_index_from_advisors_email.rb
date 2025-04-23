class RemoveUniqueIndexFromAdvisorsEmail < ActiveRecord::Migration[7.2]
  def change
    remove_index :advisors, name: "index_advisors_on_email"
    add_index :advisors, :email 
  end
end
