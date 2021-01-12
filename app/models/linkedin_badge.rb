class LinkedinBadge < Badge
  def self.instance
    first or create name: "LinkedIn", points: 50
  end
end
