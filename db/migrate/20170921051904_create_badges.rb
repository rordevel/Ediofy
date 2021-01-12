class CreateBadges < ActiveRecord::Migration[5.0]
  def change
    create_table :badges do |t|
      t.string :type
      t.string :name, null: false
      t.integer :points
      t.string :image
      t.integer :value

      t.timestamps
    end
  end
end
