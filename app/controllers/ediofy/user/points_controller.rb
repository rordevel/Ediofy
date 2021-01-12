# TODO not using in BETA
class Ediofy::User::PointsController < Ediofy::UserController
  before_action :prepare_points

  protected

  def prepare_points
    @points = @user.points
  end
end
