class AddCommentCountToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :questions, :comments_count, :integer, default: 0
    Question.find_each { |l| Question.reset_counters(l.id, :comments) }
  end
end
