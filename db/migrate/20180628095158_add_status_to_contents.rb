class AddStatusToContents < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :status, :integer, default: 0
    add_column :links, :status, :integer, default: 0
    add_column :media, :status, :integer, default: 0
  end
end
