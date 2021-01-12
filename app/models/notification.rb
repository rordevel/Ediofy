class Notification < ActiveRecord::Base
  
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :notifiable, :polymorphic => true
  scope :read, -> { where( read: true ) }
  scope :unread, -> { where( read: false ) }
  paginates_per 10
  # serialize :links

  def mark_as_read
    update_attribute :read, true
  end

  def links
    super || []
  end

end