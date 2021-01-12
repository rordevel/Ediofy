class CreateReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :references do |t|
      t.string :title
      t.string :url, null: false
      t.integer :referenceable_id
      t.string :referenceable_type
    end
  end
end
