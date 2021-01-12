class CreateTimeSpents < ActiveRecord::Migration[5.0]
  def change
    create_table :cpd_times do |t|
      t.references :user
      t.references :activity
      t.integer :value

      t.timestamps
    end
  end
end
