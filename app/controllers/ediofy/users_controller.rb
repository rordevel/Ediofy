# frozen_string_literal: true

class Ediofy::UsersController < EdiofyController
  include FilterResult
  before_action :set_user, only: %i[show cpd_report pdf_cpd_report]
  before_action :set_cpd_times, only: %i[cpd_report pdf_cpd_report]

  def index
    @query = params[:query] || ''
    @order_by = params[:order_by]
    @direction = params[:direction]

    @users = User.advanced_search query: @query,
                                  order_by: @order_by,
                                  direction: @direction

    @users = @users.page params[:page]

    respond_with @users
  end

  def show
    save_view_history(@user)
    @total_interests = Tag.where(id: @user.interests.pluck(:id)).count
    if @total_interests.positive?
      @interests = Tag.where(id: @user.interests.pluck(:id)).limit(4)
    end
    type = params[:type].blank? ? 'contribution' : params[:type].downcase
    if current_user == @user || !@user.ghost_mode
      type == 'history' ? user_history : user_contributions
    end

    @showPending = FollowRequest.where(follower_id: current_user.id, followee_id: params[:id]).limit(1).blank? ? false : true

    respond_to do |format|
      format.html
      format.js
    end
  end

  def interests
    page = params[:page] || 1
    per = 4
    @user = User.find(params[:user_id])
    interests = @user.interests.pluck(:id)
    @interests = Tag.where(id: interests).page(page).per(per)
  end

  def redirect_to_me
    redirect_to ediofy_user_activities_path(current_user), status: :temporary_redirect
  end

  def cpd_report; end

  def update_cpd_times_range
    case params['@user']['range_filter']
    when 'week'
      from_date = Time.zone.today.beginning_of_week
      to_date = Date.today

    when 'month'
      from_date = Time.zone.today.beginning_of_month
      to_date = Time.zone.today.end_of_month

    when 'year'
      from_date = Time.zone.today.beginning_of_year
      to_date = Time.zone.today.end_of_year

    when 'alltime'
      from_date = current_user.created_at
      to_date = Time.zone.today.end_of_day

    else 
      from_date = params['from']
      to_date = params['to']
    end

    # convert it to dates
    # update cpd_times with real date
    current_user.update_columns(cpd_from: from_date) unless from_date.equal?(current_user.cpd_from)
    current_user.update_columns(cpd_to: to_date) unless to_date.equal?(current_user.cpd_to)

    respond_to do |format|
      format.html { redirect_back(fallback_location: user_root_path) }
      format.js
    end
  end

  def update_cpd_comment
    cpd_time = CpdTime.find(params[:id])
    cpd_time.update(comment: params[:comment])

    render json: { status: :ok }
  end

  def pdf_cpd_report
    cpd_report_service = CpdReportPdfService.new(@user, @cpd_times, @learning, @teaching, params[:from], params[:to], params[:include_comment])
    pdf = cpd_report_service.render_pdf

    send_data pdf, filename: 'file.pdf'
  end

  private

    def set_user
      @user = User.find params[:id]
      @pendingRequestExists = FollowRequest.where(follower_id: current_user.id, followee_id: params[:id]).limit(1).blank? ? false : true
    end

    def set_cpd_times
      @cpd_times = @user.cpd_times.enabled

      fromDate = if params[:from].present? && !params[:from].nil?
                   params[:from].to_date
                 elsif @user.cpd_from.present? && !@user.cpd_from.nil?
                   @user.cpd_from
                 else
                   @user.created_at
                 end

      current_user.update_columns(cpd_from: fromDate)

      if params[:to].present?
        toDate = params[:to].to_date
      elsif @user.cpd_to.present?
        toDate = @user.cpd_to
      else
        toDate = Time.zone.today
      end

      current_user.update_columns(cpd_to: toDate)

      @cpd_times = @cpd_times.where('cpd_times.created_at between ? and ? ', fromDate, toDate)

      @learning = @cpd_times.learning
      @teaching = @cpd_times.teaching
    end
end
