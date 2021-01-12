class AddTableMediaCollection < ActiveRecord::Migration[5.0]
  def change
    create_table :media_files do |t|
      t.references :media
      t.string :media_type
      t.string :file
      t.integer :reports_count, null: false, default: 0
      t.integer :view_count, null: false, default: 0
      t.integer :question_media_count, null: false, default: 0
      t.integer :cached_votes_up, null: false, default: 0
      t.integer :cached_votes_down, null: false, default: 0
      t.integer :status, default: 0
      t.boolean :private, null: false, default: false
      t.float :score
      t.boolean :file_processing
      t.string :file_tmp
      t.text :file_info
      t.string :duration
      t.timestamps
    end
  end
end
