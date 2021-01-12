class AddVoteCountToLink < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :votes_count, :integer, default: 0
    Link.find_each { |l| Link.reset_counters(l.id, :votes) }
  end
end
