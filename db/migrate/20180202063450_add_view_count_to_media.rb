class AddViewCountToMedia < ActiveRecord::Migration[5.0]
  def change
    remove_column :media_files, :view_count, :integer
    change_column :media, :view_count, :integer, default: 0
    change_column :users, :view_count, :integer, default: 0
    change_column :questions, :view_count, :integer, default: 0
  end
end
