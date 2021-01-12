class CreateViewHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :viewed_histories do |t|
      t.references :user
      t.references :viewable, polymorphic: true
      t.timestamps
    end
  end
end
