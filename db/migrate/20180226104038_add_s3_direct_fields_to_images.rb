class AddS3DirectFieldsToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :s3_file_name, :string
    add_column :images, :s3_file_url, :string
    add_column :images, :position, :integer, default: 0
  end
end
