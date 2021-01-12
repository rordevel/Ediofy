class CreateTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :topics do |t|
      t.references :product
      t.string :title
      t.string :ancestry
      t.string :site, default: 'imed'

      t.timestamps
    end
    add_index :topics, :site
  end
end
