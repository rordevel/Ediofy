# TODO not being used in BETA
class FacebookBadge < Badge
  def self.instance
    first or create name: "Facebook", points: 50
  end
end
