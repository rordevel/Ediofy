class AddVoteCountToConversation < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :votes_count, :integer, default: 0
    Conversation.find_each { |l| Conversation.reset_counters(l.id, :votes) }
  end
end
