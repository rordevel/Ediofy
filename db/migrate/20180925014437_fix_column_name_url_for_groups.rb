class FixColumnNameUrlForGroups < ActiveRecord::Migration[5.0]
  def change
  	 rename_column :groups, :url, :group_url
  end
end
