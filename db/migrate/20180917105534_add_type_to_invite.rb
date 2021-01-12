class AddTypeToInvite < ActiveRecord::Migration[5.0]
  def change
    add_column :group_invites, :invite_type, :string
  end
end
