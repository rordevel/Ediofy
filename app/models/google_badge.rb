class GoogleBadge < Badge
  def self.instance
    first or create name: "Google", points: 50
  end
end
