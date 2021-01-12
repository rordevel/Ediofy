class CreateDefaultPlaceholders < ActiveRecord::Migration[5.0]
  def change
    create_table :default_placeholders do |t|
      t.integer :number
      t.references :placeholderable, polymorphic: true, index: {:name => "index_my_shorter_name"}
    end
  end
end
