class CreateMediaMediaCollections < ActiveRecord::Migration[5.0]
  def change
    create_table :media_media_collections, id: false do |t|
      t.references :media, null: false
      t.references :media_collection, null: false
      t.integer :sort, null: false, default: 0
    end

    # Automatic index names are too long
    add_index :media_media_collections, [:media_id, :media_collection_id], unique: true, name: "index_media_to_media_collection"
    add_index :media_media_collections, [:media_collection_id, :media_id], name: "index_media_collection_to_media"
    add_column :media_media_collections, :id, :primary_key
  end
end
