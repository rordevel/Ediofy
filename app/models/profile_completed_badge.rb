class ProfileCompletedBadge < Badge
  def self.instance
    first or create name: "Profile Completed", points: 50, cpd_time: 60*15
  end
end
