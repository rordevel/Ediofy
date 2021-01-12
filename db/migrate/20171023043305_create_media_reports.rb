class CreateMediaReports < ActiveRecord::Migration[5.0]
  def change
    create_table :media_reports do |t|
      t.references :media
      t.references :user
      t.string :reason

      t.timestamps
    end
  end
end
