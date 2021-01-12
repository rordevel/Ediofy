class CreateMediaConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :media_conversations do |t|
      t.belongs_to :media, foreign_key: true
      t.belongs_to :conversation, foreign_key: true

      t.timestamps
    end
  end
end
