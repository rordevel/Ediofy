class AddEnabledToActivityKeyPointValues < ActiveRecord::Migration[5.1]
  def change
    add_column :activity_key_point_values, :enabled, :boolean
  end
end
