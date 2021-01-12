class AddCommentCountToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :comments_count, :integer, default: 0
    Conversation.find_each { |l| Conversation.reset_counters(l.id, :comments) }
  end
end
