class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.belongs_to :user, foreign_key: true
      t.string :url
      t.string :title
      t.string :page_image
      t.string :page_description
      t.text :description
      t.integer :view_count, default: 0
      t.timestamps
    end
  end
end
