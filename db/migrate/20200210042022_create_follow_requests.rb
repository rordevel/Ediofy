class CreateFollowRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :follow_requests do |t|
      t.references :follower
      t.references :followee

      t.timestamps
    end
  end
end
