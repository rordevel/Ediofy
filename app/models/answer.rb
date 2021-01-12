class Answer < ActiveRecord::Base
  belongs_to :question
  has_many   :selected_answers

  scope :correct, -> { where( correct: true ) }
  scope :incorrect, -> { where( correct: false ) }

  validates_presence_of :body
  validates_presence_of :question, on: :update

  translates :body

  # amoeba do
  #   enable
  #   exclude_field :selected_answers
  #   clone [
  #     :translations
  #   ]
  # end

  def name
    body
  end

  def answered_correct_by user
    self.selected_answers.joins(question:[user_exam_questions:[:ediofy_user_exam]]).where( answers: { correct: true }, ediofy_user_exams: { user_id: user.id } ).count >= 1
  end
end