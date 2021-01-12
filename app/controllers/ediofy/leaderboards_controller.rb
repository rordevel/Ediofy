#TODO not using in BETA
class Ediofy::LeaderboardsController < EdiofyController

  before_action :prepare_users_scope

  def show
    this_month
  end

  def this_week
    @start = Date.today.beginning_of_week
    @finish = Date.today.end_of_week
    @endsin = (@finish - Date.today).to_i
    @users = @scope.with_ranks_this_week.order("rank").page current_page#, per_page: per_page)
  end

  def this_month
    @start = Date.today.beginning_of_month
    @finish = Date.today.end_of_month
    @endsin = (@finish - Date.today).to_i
    @users = @scope.with_ranks_this_month.order("rank").page current_page#, per_page: per_page)
  end

  def all_time
    @users = @scope.with_ranks.order("rank").page current_page#, per_page: per_page)
  end

protected

  def current_page
    params[:page] || if user_signed_in?
      (leaderboard_rank_for(current_user) / per_page).ceil + 1
    end
  end

  def per_page
    20
  end

  def leaderboard_points_for user
    case action_name
      when "this_week", "this_month"
        user.points.send(action_name).total
      when "show"
        user.points.this_month.total
      when "all_time"
        user.points.total
      else
        user.points.total
    end
  end

  def leaderboard_rank_for user
    case action_name
      when "this_week"
        user.rank_this_week
      when "this_month", "show"
        user.rank_this_month
      else
        user.rank_all_time
    end
  end

  def prepare_users_scope
    @scope = User
  end

  helper_method :leaderboard_points_for, :leaderboard_rank_for
end
