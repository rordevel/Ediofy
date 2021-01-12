# TODO not using in BETA
class Ediofy::Users::InvitesController < EdiofyController

  # Loaded via AJAX
  def network_users
    render partial: "network_users"
  end

  def create
    begin
      addresses = Mail::AddressList.new(params[:emails]).addresses
      addresses.each do |address|
        user=User.where(email: address.to_s).first
        if user
          current_user.request_friend(user)
        else
          EdiofyMailer.invite(current_user, address.to_s).deliver_later
        end
      end
      redirect_to ediofy_user_invites_path, notice: t('ediofy.users.invites.create.success', count: addresses.length)
    rescue Mail::Field::ParseError
      flash.now[:alert] = t('ediofy.users.invites.create.invalid')
      render :index
    end
  end
end
