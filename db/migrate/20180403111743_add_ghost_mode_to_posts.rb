class AddGhostModeToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :private, :boolean, default: false
    add_column :links, :private, :boolean, default: false
    add_column :comments, :private, :boolean, default: false
  end
end
