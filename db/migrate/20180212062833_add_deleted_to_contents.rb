class AddDeletedToContents < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :deleted , :boolean, default: false
    add_column :links, :deleted , :boolean, default: false
    add_column :media, :deleted , :boolean, default: false
    add_column :questions, :deleted , :boolean, default: false
  end
end
