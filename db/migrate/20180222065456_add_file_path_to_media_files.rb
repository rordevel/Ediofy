class AddFilePathToMediaFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :media_files, :file_path, :string
  end
end
