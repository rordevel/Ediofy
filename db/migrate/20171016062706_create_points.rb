class CreatePoints < ActiveRecord::Migration[5.0]
  def change
    create_table :points do |t|
      t.references :user
      t.references :activity
      t.integer :value

      t.timestamps
    end
  end
end
