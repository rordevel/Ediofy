class RemoveTables < ActiveRecord::Migration[5.0]
  def self.up
    drop_table :media_media_collections
    drop_table :media_questions
    drop_table :media_conversations
  end

  def self.down
    create_table :media_media_collections, id: false do |t|
      t.references :media, null: false
      t.references :media_collection, null: false
      t.integer :sort, null: false, default: 0
    end

    # Automatic index names are too long
    add_index :media_media_collections, [:media_id, :media_collection_id], unique: true, name: "index_media_to_media_collection"
    add_index :media_media_collections, [:media_collection_id, :media_id], name: "index_media_collection_to_media"
    add_column :media_media_collections, :id, :primary_key
  
    create_table :media_questions do |t|
      t.references :media, null: false
      t.references :question, null: false
    end
    add_index :media_questions, [:question_id, :media_id], unique: true
    add_index :media_questions, [:media_id, :question_id]

    create_table :media_conversations do |t|
      t.belongs_to :media, foreign_key: true
      t.belongs_to :conversation, foreign_key: true

      t.timestamps
    end
  end
end
