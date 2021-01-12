class AddScoreToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :score, :float
  end
end
