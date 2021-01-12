class AddVoteCountToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :votes_count, :integer, default: 0
    User.find_each { |l| User.reset_counters(l.id, :votes) }
  end
end
