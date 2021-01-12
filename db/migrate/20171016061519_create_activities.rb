class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.references :user

      t.string :key, null: false
      # Serialized
      t.text :variables
      t.text :relation_ids
      
      t.text :ancestry
      t.timestamps
    end
    add_index :activities, :key
    add_index :activities, [:user_id, :key]
  end
end
