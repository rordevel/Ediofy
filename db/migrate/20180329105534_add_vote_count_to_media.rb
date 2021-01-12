class AddVoteCountToMedia < ActiveRecord::Migration[5.0]
  def change
    add_column :media, :votes_count, :integer, default: 0
    Media.find_each { |l| Media.reset_counters(l.id, :votes) }
  end
end
