class AddProfileCompletedIndexToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :profile_completed
  end
end
