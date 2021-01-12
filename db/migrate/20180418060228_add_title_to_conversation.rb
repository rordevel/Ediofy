class AddTitleToConversation < ActiveRecord::Migration[5.0]
  def up
    add_column :conversations, :title, :string
  end
  def down
    remove_column :conversations, :title, :string
  end
end
