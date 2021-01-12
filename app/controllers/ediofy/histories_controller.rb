class Ediofy::HistoriesController < EdiofyController
  include FilterResult
  def index
    user_history
  end
end