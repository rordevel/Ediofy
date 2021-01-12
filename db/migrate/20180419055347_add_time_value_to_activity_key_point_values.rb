class AddTimeValueToActivityKeyPointValues < ActiveRecord::Migration[5.0]
  def change
    add_column :activity_key_point_values, :cpd_time, :integer, default: 0
  end
end
