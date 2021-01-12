class AddDefaultLocaleToUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :locale, :string, default: "en"
  end
end
