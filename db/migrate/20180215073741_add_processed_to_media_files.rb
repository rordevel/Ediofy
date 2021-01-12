class AddProcessedToMediaFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :media_files, :extension, :string
    add_column :media_files, :processed, :boolean, default: false
  end
end
