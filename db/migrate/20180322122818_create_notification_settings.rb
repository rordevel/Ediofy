class CreateNotificationSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :notification_settings do |t|
      t.references :user
      t.boolean :notify_follows, default: false
      t.boolean :notify_comments, default: false
      t.boolean :notify_likes, default: false
      t.boolean :notify_tags, default: false
      t.boolean :notify_followed_contributor_post, default: false

      t.boolean :email_follows, default: false
      t.boolean :email_comments, default: false
      t.boolean :email_likes, default: false
      t.boolean :email_tags, default: false

      t.timestamps
    end
  end
end
