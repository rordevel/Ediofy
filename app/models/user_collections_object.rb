class UserCollectionsObject < ActiveRecord::Base
  belongs_to :user_collection
  belongs_to :objectable, polymorphic: true

  validates :user_collection, :objectable, presence: true
end