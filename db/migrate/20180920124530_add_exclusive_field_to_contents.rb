class AddExclusiveFieldToContents < ActiveRecord::Migration[5.0]
  def change
    add_column :media, :group_exclusive, :boolean, default: false
    add_column :links, :group_exclusive, :boolean, default: false
    add_column :questions, :group_exclusive, :boolean, default: false
    add_column :conversations, :group_exclusive, :boolean, default: false
  end
end
