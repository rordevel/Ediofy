class AddNotifiableToNotifications < ActiveRecord::Migration[5.0]
  def up
    change_table :notifications do |t|
      t.references :notifiable, polymorphic: true
    end
  end

  def down
    change_table :notifications do |t|
      t.remove_references :notifiable, polymorphic: true
    end
  end
end
