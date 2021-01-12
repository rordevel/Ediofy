class AddApprovedIndexToQuestion < ActiveRecord::Migration[5.0]
  def change
    add_index :questions, :approved
  end
end
