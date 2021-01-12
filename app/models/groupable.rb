module Groupable
  extend ActiveSupport::Concern

  included do
    after_save :touch_groups
    after_touch :touch_groups

    def touch_groups
      self.groups.all.each(&:touch)
    end
  end
end
