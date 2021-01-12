class AddNotifyGroupMemberPlaylistPostToNotificationSettings < ActiveRecord::Migration[5.0]
  def change
  	  add_column :notification_settings, :notify_group_members_playlist_post, :boolean, default: false
  end
end
