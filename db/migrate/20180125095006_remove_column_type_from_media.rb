class RemoveColumnTypeFromMedia < ActiveRecord::Migration[5.0]
  def change
    remove_column :media, :media_type, :string
    rename_column :media, :type,:new_type
    remove_column :media, :file_processing, :string
    remove_column :media, :file_tmp, :string
    remove_column :media, :file_info, :string
    remove_column :media, :status, :string
    remove_column :media, :duration, :string
  end
end
