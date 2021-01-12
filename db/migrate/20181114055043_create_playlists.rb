class CreatePlaylists < ActiveRecord::Migration[5.0]
  def change
    create_table :playlists do |t|
      t.string :title
      t.string :description
      t.boolean :archived
      t.references :group
      t.references :user

      t.timestamps
    end
  end
end




