class CreateAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :announcements do |t|
      t.string :text
      t.integer :comments_count, default: 0
      t.references :group
      t.references :user

      t.timestamps
    end
  end
end
