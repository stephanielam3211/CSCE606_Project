# frozen_string_literal: true

class AddAdminToRecommendations < ActiveRecord::Migration[7.2]
  def change
    add_column :recommendations, :admin, :boolean
  end
end
