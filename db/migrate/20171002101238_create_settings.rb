class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.references :user
      t.text :topic_choice
      t.integer :privacy_public, null: false, default: 1
      t.integer :privacy_friends, null: false, default: 1
      t.datetime :question_reset_date
      t.string :question_reset, null: false, default: 'exhausted'
      t.boolean :send_updates, default: true
    end
  end
end
