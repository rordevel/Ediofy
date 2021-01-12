class AddVoteCountToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :votes_count, :integer, default: 0
    Question.find_each { |l| Question.reset_counters(l.id, :votes) }
  end
end
