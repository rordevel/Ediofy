class AddProfileFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :display_name, :string
    add_column :users, :biography, :string
    add_column :users, :avatar, :string
    add_column :users, :locale, :string
    add_column :users, :website, :string
  end
end
