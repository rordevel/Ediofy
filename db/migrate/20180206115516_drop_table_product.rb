class DropTableProduct < ActiveRecord::Migration[5.0]
  def self.up
    drop_table :products
  end
  def self.down
    create_table :products do |t|
      t.string :title
      t.text :description
      t.integer :monthly_price_in_cents
      t.boolean :active, default: false
      t.string :short_title, null: false
      t.integer :trial_period, null: false, default: 0
    end
  end
end
