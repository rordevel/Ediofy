class ChangeGroupNameToTitle < ActiveRecord::Migration[5.0]
  def change
    rename_column :groups, :name, :title
    add_column :groups, :comments_count, :integer, default: 0
    add_column :groups, :votes_count, :integer, default: 0
    add_column :groups, :view_count, :integer, default: 0
  end
end
