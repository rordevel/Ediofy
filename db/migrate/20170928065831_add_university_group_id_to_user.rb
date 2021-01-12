class AddUniversityGroupIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :university_group_id, :integer
    add_index :users, :university_group_id
  end
end
