class ChangeMemberType < ActiveRecord::Migration[5.0]
  def change
    change_column :group_memberships, :member_type, :string, null: true
  end
end
