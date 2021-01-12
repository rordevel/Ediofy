class AddCpdTimeToBadges < ActiveRecord::Migration[5.0]
  def change
    add_column :badges, :cpd_time, :integer, default: 0
  end
end
