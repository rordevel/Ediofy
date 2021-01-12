class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provider, :string, :null => false, :default => "email"
    add_column :users, :uid, :string, :null => false, :default => ""
    add_column :users, :tokens, :json
    add_column :users, :device_token, :string
    add_column :users, :device_type, :string
    add_column :users, :uuid_iphone, :string
  end
end
