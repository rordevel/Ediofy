class AddGhostModeIndexToUser < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :ghost_mode
  end
end
