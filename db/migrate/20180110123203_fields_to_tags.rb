class FieldsToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :tag_type, :integer, default: 0
    add_column :tags, :ancestry, :string
    add_column :tags, :image, :string
  end
end
