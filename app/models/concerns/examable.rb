module Examable

  extend ActiveSupport::Concern

  included do
    scope :finished, -> { where(finished: true) }
    scope :unfinished, -> { where(finished: false) }
    scope :unpaused, -> { where(paused_at: nil) }
    scope :paused, -> { where{ paused_at.not_eq nil } }

    belongs_to :user

    has_many :exam_questions, -> { order(:position) }, as: :user_exam, inverse_of: :user_exam, class_name: 'UserExamQuestion'
    has_many :selected_answers, through: :exam_questions
    has_many :questions, through: :exam_questions

    validates :user, :presence => true

  end

  def questions_total
    exam_questions.count
  end

  def questions_completed
    selected_answers.count
  end

  def questions_unanswered
    questions_total - questions_completed
  end

  def questions_completed_percentage
    return 0.0 if questions_total == 0

    questions_completed.to_f / questions_total.to_f
  end

  def questions_correct
    selected_answers.joins(:answer).where(answer: { correct: true }).count
  end

  # returns the percentage of answers which are correct
  # e.g. 10 questions, 5 have been answered, 3 answers are correct.  method will return 0.6 ( 3/5 ~ 60% )
  def questions_correct_percentage
    return 0.0 if questions_completed == 0

    questions_correct.to_f / questions_completed.to_f
  end

  # returns the percentage of questions with correct answers
  # e.g. 10 questions, 5 have been answered, 3 answers are correct.  method will return 0.3 ( 3/10 ~ 30% )
  def total_questions_correct_percentage
    return 0.0 if exam_questions.empty?

    questions_correct.to_f / questions_total.to_f
  end

  def questions_incorrect
    questions_completed - questions_correct
  end

  def questions_incorrect_percentage
    return 0.0 if questions_completed == 0

    1.0 - questions_correct_percentage
  end

  def all_questions_answered?
    selected_answers.count == exam_questions.count
  end

  def next_unanswered_question
    # Last so that we wrap around to the first
    exam_questions.last.next_unanswered
  end

end