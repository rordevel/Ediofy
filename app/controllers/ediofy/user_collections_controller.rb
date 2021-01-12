# TODO not using in Beta
class Ediofy::UserCollectionsController < EdiofyController

  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :prepare_scope
  before_action :build_user_collection, only: [:new, :create]
  before_action :prepare_user_collection, except: [:new, :create, :index]

  def index
    @query = params[:query] || ""
    @order_by = params[:order_by]
    @direction = params[:direction]
    @limit = params[:limit]
    @collections = UserCollection.advanced_search query: @query,
                                                    order_by: @order_by,
                                                    direction: @direction,
                                                    limit: @limit,
                                                    user: current_user
    @collections = @collections.page params[:page]
    respond_with @collections
  end

  def show
    @questions = @collection.questions.visible_to current_user
    @media = @collection.media.visible_to current_user
  end

  def new
    respond_with :ediofy, @collection
  end

  def edit
    if current_user != @collection.user
      redirect_back fallback_location: ediofy_root_url, alert: 'Unauthorized Access'
    else
      respond_with :ediofy, @collection
    end
  end

  def update
    if current_user != @collection.user
      redirect_back fallback_location: ediofy_root_url, alert: 'Unauthorized Access'
    else
      @collection.update_attributes(user_collection_params)
      respond_with :ediofy, @collection
    end
  end

  def destroy
    if current_user != @collection.user
      redirect_back fallback_location: ediofy_root_url, alert: 'Unauthorized Access'
    else
      @collection.destroy
      respond_with :ediofy, @collection
    end
  end

  def create
    @collection.save
    respond_with :ediofy, @collection
  end


  private

  def user_collection_params
    params.require(:user_collection).permit(:title, :description, :private)  
  end

  def build_user_collection
    @collection = current_user.user_collections.new params[:user_collection].present? ? user_collection_params : nil
  end

  def prepare_scope
    @scope = UserCollection.visible_to current_user
  end

  def prepare_user_collection
    @collection = @scope.find params[:id]
  end

end