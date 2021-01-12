class CreateMedia < ActiveRecord::Migration[5.0]
  def change
    create_table :media do |t|
      t.references :user
      t.string :title
      t.string :media_type
      t.text :description
      t.string :file
      t.integer :reports_count, null: false, default: 0
      t.integer :view_count, null: false, default: 0
      t.integer :question_media_count, null: false, default: 0
      t.integer :cached_votes_up, null: false, default: 0
      t.integer :cached_votes_down, null: false, default: 0
      t.boolean :private, null: false, default: false
      t.string :type
      t.float :score
      t.boolean :file_processing
      t.string :file_tmp
      t.text :file_info

      t.timestamps
    end
  end
end
