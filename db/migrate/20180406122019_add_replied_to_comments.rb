class AddRepliedToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :replied_to, :integer
  end
end
