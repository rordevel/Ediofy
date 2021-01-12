class CreateActivityKeyPointValues < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_key_point_values do |t|
      t.string :activity_key, null: false
      t.integer :point_value, null: false, default: 0
      t.timestamps
    end
    add_index :activity_key_point_values, :activity_key, unique: true
  end
end
