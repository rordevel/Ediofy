class Ediofy::Users::ConfirmationsController < Devise::ConfirmationsController

  private
  def after_confirmation_path_for(resource_name, resource)
    email_verification_succ_path
  end
end