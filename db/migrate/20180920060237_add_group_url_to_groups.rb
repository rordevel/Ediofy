class AddGroupUrlToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :url, :string
  end
end
