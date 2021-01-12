# TODO not being used in BETA
class EarlyAdopterBadge < Badge
  def self.instance
    first or create name: "Early Adopter"
  end
end
