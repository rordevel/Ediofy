class CreateUserCollectionsObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :user_collections do |t|
      t.references :user
      t.string :title
      t.text :description
      t.boolean :private, null: false, default: false
      t.timestamps
    end
    create_table :user_collections_objects do |t|
      t.references :user_collection
      t.integer :objectable_id, null: false
      t.string :objectable_type, null: false
    end
  end
end
