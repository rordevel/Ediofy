class GroupInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  def accept!
    update(accepted: true)
    if self.invite_type == :request
      self.user.notifications.create! title: "Your request to join '#{self.group.title}' group was accepted!"
    else
      self.user.notifications.create! title: "You accept request to join group '#{self.group.title}'"
    end
    group.users << user
  end

  def decline!
    update(accepted: false)
    if self.invite_type == :request
      self.user.notifications.create! title: "Your request to join '#{self.group.title}' group was declined!"
    else
      self.user.notifications.create! title: "You decline request to join group '#{self.group.title}'"
    end
  end
end