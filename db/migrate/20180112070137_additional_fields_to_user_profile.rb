class AdditionalFieldsToUserProfile < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :full_name, :string
  	add_column :users, :title, :integer
  	change_column :users, :specialty, 'integer USING CAST(specialty AS integer)'
  	add_column :users, :about, :string
  end
end
