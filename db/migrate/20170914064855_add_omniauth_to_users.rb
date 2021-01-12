class AddOmniauthToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :twitter_uid, :string
    add_index  :users, :twitter_uid, unique: true
    add_column :users, :twitter_auth, :text

    add_column :users, :facebook_uid, :string
    add_index  :users, :facebook_uid, unique: true
    add_column :users, :facebook_auth, :text

    add_column :users, :google_uid, :string
    add_index  :users, :google_uid, unique: true
    add_column :users, :google_auth, :text

    add_column :users, :linkedin_uid, :string
    add_index  :users, :linkedin_uid, unique: true
    add_column :users, :linkedin_auth, :text
  end
end
