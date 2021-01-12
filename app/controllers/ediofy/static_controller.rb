# TODO not using in BETA
class Ediofy::StaticController < EdiofyController

  def about
    @enquiry = Enquiry.new
  end

end