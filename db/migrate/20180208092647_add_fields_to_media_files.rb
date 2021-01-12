class AddFieldsToMediaFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :media_files, :s3_file_url, :string
    add_column :media_files, :s3_file_name, :string
    add_column :media_files, :position, :integer, default: 0
  end
end
