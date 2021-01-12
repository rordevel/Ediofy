class QuestionExplanation < ActiveRecord::Base

  belongs_to :user
  belongs_to :question
  validates :user, :question, :locale, :body, presence: true

end
