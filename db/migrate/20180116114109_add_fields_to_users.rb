class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_completed, :boolean, default: false
    add_column :users, :interests_selected, :boolean, default: false
    add_column :users, :follows_selected, :boolean, default: false
  end
end
