class AddCourseToRecommendations < ActiveRecord::Migration[7.2]
  def change
    add_column :recommendations, :course, :string
  end
end
