class CreateUniversities < ActiveRecord::Migration[5.0]
  def change
    create_table :universities do |t|
      t.string :name
      t.string :abbreviation
      t.text :description
      t.string :website
      t.string :country
      t.integer :members_count, null: false, default: 0
      t.string :badge
      t.timestamps
    end
    add_index :universities, [:name, :country, :members_count]
  end
end
