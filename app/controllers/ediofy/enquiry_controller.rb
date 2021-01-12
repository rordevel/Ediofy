#TODO not using in BETA
class Ediofy::EnquiryController < EdiofyController

  def create
    @enquiry = Enquiry.new(params[:enquiry])
    @enquiry.send_email if @enquiry.valid? # Validates the model (we don't save as we're not using the DB)
    respond_with @enquiry, location: ediofy_contact_thanks_path
  end

end