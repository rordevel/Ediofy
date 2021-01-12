class GroupMembership < ActiveRecord::Base
  belongs_to :member, foreign_key: :member_id, class_name: 'User'
  belongs_to :owner,  foreign_key: :member_id, class_name: 'User'
  belongs_to :admin,  foreign_key: :member_id, class_name: 'User'
  belongs_to :user,   foreign_key: :member_id, class_name: 'User'
  belongs_to :group
end
