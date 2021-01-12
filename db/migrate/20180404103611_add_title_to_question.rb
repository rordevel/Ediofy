class AddTitleToQuestion < ActiveRecord::Migration[5.0]
  def up
    add_column :questions, :title, :string
  end
end
