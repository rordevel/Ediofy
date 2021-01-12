class ChangePostedAsGroupToBeInteger < ActiveRecord::Migration[5.0]
  def change
	remove_column :media, :posted_as_group, :boolean
	remove_column :links, :posted_as_group, :boolean
	remove_column :questions, :posted_as_group, :boolean
	remove_column :conversations, :posted_as_group, :boolean
	add_column :media, :posted_as_group, :integer
	add_column :links, :posted_as_group, :integer
	add_column :questions, :posted_as_group, :integer
	add_column :conversations, :posted_as_group, :integer
 end
end
