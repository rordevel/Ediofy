class AddCommentCountToMedia < ActiveRecord::Migration[5.0]
  def change
    add_column :media, :comments_count, :integer, default: 0
    Media.find_each { |l| Media.reset_counters(l.id, :comments) }
  end
end
