class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.references :user
      t.integer :question_source_id
      t.string :difficulty
      t.string :question_image
      t.boolean :active
      t.string :site, not_null: true, default: 'imed'
      t.boolean :approved
      t.float :score, default: 0.0
      t.integer :question_media_count, null: false, default: 0
      t.boolean :private, null: false, default: false
      t.text :ancestry

      t.timestamps
    end
  end
end
