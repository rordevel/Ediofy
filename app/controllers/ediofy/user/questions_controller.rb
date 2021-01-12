# TODO not using in BETA
class Ediofy::User::QuestionsController < Ediofy::UserController
  def index
    @questions = @user.questions.order('created_at DESC').page params[:page]
  end
end