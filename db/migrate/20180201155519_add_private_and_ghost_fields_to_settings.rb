class AddPrivateAndGhostFieldsToSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :ghost_mode, :boolean, default: false
    add_column :settings, :private, :boolean, default: false
  end
end
