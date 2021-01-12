class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|
      t.text :description
      t.string :summary
      t.string :subject
      t.belongs_to :user, foreign_key: true
      t.timestamps
    end
  end
end
