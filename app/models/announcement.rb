class Announcement < ApplicationRecord

  acts_as_votable cacheable_strategy: :update_columns
  acts_as_commentable

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reports, as: :reportable
  has_many :votes, as: :votable
  belongs_to :group
  belongs_to :user

  # stubs for voteable
  def title; end
end
