class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true
      t.string :file
      t.boolean :file_processing, null: false, default: false
      t.string :file_tmp
      t.text :file_info
      t.timestamps
    end
  end
end
