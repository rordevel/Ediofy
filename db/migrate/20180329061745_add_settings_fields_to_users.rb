class AddSettingsFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ghost_mode, :boolean, default: false
    add_column :users, :private, :boolean, default: false
  end
end
