class CreateRecommendations < ActiveRecord::Migration[7.2]
  def change
    create_table :recommendations do |t|
      t.string :email
      t.string :name
      t.string :selectionsTA
      t.text :feedback
      t.text :additionalfeedback

      t.timestamps
    end
  end
end
