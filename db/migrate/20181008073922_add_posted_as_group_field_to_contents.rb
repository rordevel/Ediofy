class AddPostedAsGroupFieldToContents < ActiveRecord::Migration[5.0]
  def change
  	add_column :media, :posted_as_group, :boolean, default: false
    add_column :links, :posted_as_group, :boolean, default: false
    add_column :questions, :posted_as_group, :boolean, default: false
    add_column :conversations, :posted_as_group, :boolean, default: false
  end
end
