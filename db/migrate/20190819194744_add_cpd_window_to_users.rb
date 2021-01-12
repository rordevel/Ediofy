class AddCpdWindowToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cpd_from, :string
    add_column :users, :cpd_to, :string
  end
end
