class GroupInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :group_invites do |t|
      t.references :user
      t.references :group
      t.boolean :accepted

      t.timestamps
    end
  end
end
