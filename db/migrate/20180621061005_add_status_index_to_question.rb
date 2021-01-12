class AddStatusIndexToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_index :questions, :status
  end
end
