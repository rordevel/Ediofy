class Ediofy::TermsController < EdiofyController
  skip_before_action :ensure_on_boarding_process_completed
  skip_before_action :authenticate_user!, only: :show
  before_action :redirect_back_if_already_accepted, only: :create

  def create
    current_user.update_attribute :ediofy_terms_accepted, true
    redirect_to user_root_path
  end

protected

  def redirect_back_if_already_accepted
    if user_signed_in? && current_user.ediofy_terms_accepted?
      redirect_to user_root_path
    end
  end
end
