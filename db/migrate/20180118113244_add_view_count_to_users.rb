class AddViewCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :view_count, :integer, defualt: 0
    add_column :questions, :view_count, :integer, defualt: 0
  end
end
