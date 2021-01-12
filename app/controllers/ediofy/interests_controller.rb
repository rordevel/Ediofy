class Ediofy::InterestsController < EdiofyController
	skip_before_action :ensure_on_boarding_process_completed
  def index
    check_and_reset_user_onboarding_state
    @interests = Tag.where("tag_type= ? and ancestry is null",Tag.tag_types[:Interest]).order("name ASC")
  end
	  
end
