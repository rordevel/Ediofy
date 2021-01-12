class AddDeletedIndexToLink < ActiveRecord::Migration[5.0]
  def change
    add_index :links, :deleted
  end
end
