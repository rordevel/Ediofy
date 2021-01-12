class AddCommentToCpdTimes < ActiveRecord::Migration[5.1]
  def change
    add_column :cpd_times, :comment, :text
  end
end
