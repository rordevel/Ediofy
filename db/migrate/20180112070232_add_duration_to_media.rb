class AddDurationToMedia < ActiveRecord::Migration[5.0]
  def change
    add_column :media, :duration, :string
  end
end
