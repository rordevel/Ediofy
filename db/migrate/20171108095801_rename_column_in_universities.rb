class RenameColumnInUniversities < ActiveRecord::Migration[5.0]
  def change
    rename_column :universities, :members_count, :users_count
  end
end
