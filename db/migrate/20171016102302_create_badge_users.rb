class CreateBadgeUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :badge_users do |t|
      t.references :badge
      t.references :user
      t.string :reason_key, null: false
      # Serialized
      t.text :reason_relation_ids
      t.text :reason_variables

      t.timestamps
    end
  end
end
