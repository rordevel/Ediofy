class AddDefaultPhotoContentIdToPlaylists < ActiveRecord::Migration[5.0]
  def change
  	add_column :playlists, :default_photo, :string
  end
end
