class TwitterBadge < Badge
  def self.instance
    first or create name: "Twitter", points: 50
  end
end
