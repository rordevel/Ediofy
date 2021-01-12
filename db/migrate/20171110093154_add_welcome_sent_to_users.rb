class AddWelcomeSentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :welcome_sent, :boolean, null: false, default: false
  end
end
