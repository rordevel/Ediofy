class AddGroupToComments < ActiveRecord::Migration[5.1]
  def change
    add_reference :comments, :group, foreign_key: true
  end
end
