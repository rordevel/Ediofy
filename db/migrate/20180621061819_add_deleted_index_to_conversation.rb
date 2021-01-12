class AddDeletedIndexToConversation < ActiveRecord::Migration[5.0]
  def change
    add_index :conversations, :deleted
  end
end
