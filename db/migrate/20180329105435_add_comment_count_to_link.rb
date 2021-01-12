class AddCommentCountToLink < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :comments_count, :integer, default: 0
    Link.find_each { |l| Link.reset_counters(l.id, :comments) }
  end
end
