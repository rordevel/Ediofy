class AddNewFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
  	remove_column :users, :display_name, :string
  	add_column :users, :location, :string
  	add_column :users, :specialty, :string
  	add_column :users, :qualifications, :string
  end
end
