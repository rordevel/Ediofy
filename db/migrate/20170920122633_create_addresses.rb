class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.references :user
      t.string :street
      t.string :suburb
      t.string :state 
      t.string :postcode
      t.string :country
      t.timestamps
    end
  end
end
