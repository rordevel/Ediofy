class RemoveFieldsFromMedia < ActiveRecord::Migration[5.0]
  def change
    remove_column :media, :file, :string
  end
end
