class AddSpecialtyIdToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :specialty, :integer
    add_reference :users, :specialty, foreign_key: true
  end
end
