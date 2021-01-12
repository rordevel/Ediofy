class AddIsActiveToSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :settings, :is_active, :boolean, default: true
  end
end
