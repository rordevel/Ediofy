class AddViewCountToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :view_count, :integer, default: 0
  end
end
