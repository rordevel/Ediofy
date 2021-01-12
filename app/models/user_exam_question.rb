class UserExamQuestion < ActiveRecord::Base
  STATUS_CORRECT    = "correct"
  STATUS_INCORRECT  = "incorrect"
  STATUS_SKIPPED    = "skipped"
  STATUS_CURRENT    = "current"
  STATUS_UNANSWERED = "unanswered"
  STATUS_ANSWERED   = "answered"
  STATUS_NOT_SURE   = "not-sure"

  CORRECT_ANSWER_POINTS = 30
  CONFIDENCE_VOTE_POINTS = 10
  DIFFICULTY_VOTE_POINTS = 10
  CORRECT_ANSWER_CPD_TIME = 10*60

  STATUSES = [STATUS_CORRECT, STATUS_INCORRECT, STATUS_SKIPPED, STATUS_CURRENT, STATUS_UNANSWERED]

  acts_as_list scope: [ :user_exam_id, :user_exam_type ]

  PER_PAGE = 60

  belongs_to :user_exam, polymorphic: true
  belongs_to :ediofy_user_exam, -> { where(user_exam_questions: { user_exam_type: 'EdiofyUserExam'}) }, foreign_key: 'user_exam_id'

  belongs_to :question
  belongs_to :selected_answer
  validates :question, presence: true

  accepts_nested_attributes_for :selected_answer
  after_save :create_activity

  def selected_answer_with_build
    selected_answer_without_build || build_selected_answer
  end

  alias_method :selected_answer_without_build, :selected_answer
  alias_method :selected_answer, :selected_answer_with_build

  # We want to use the position for the parameter
  def to_param
    position.to_s
  end

  def status(current = nil, mode = :revision)

    status = []

    # Add the current status if the position matches the current question
    if current.present? && position == current
      status << STATUS_CURRENT
    end

    # check if an answer is present
    if selected_answer.answer.present?
      if mode == :mock
        status << (selected_answer.not_sure? ? STATUS_NOT_SURE : STATUS_ANSWERED)
      else
        status << (selected_answer.correct? ? STATUS_CORRECT : STATUS_INCORRECT)
      end
    else
      status << STATUS_UNANSWERED
    end

    status.join(' ')

  end

  # Returns the next question in the queue that is not answered
  # If there are no "next" unanswered questions then returns
  # the first unanswered question (it wraps around).
  def next_unanswered
    next_question  = user_exam.exam_questions.where("position > ? AND selected_answer_id = ?", position, nil).first
    next_question || user_exam.exam_questions.where(selected_answer_id: nil).first
  end
  def page_number
    per_page = (PER_PAGE.present? && PER_PAGE > 0) ? PER_PAGE : 60

    mod = position % per_page
    if mod == 0
      ((position - (position % per_page)) / per_page)
    else
      ((position - (position % per_page)) / per_page) + 1
    end
  end

  # will paginate calls CLASS.per_page.  This method just points it at the constant
  def self.per_page
    PER_PAGE
  end


  protected

  def create_activity
    if selected_answer
      user = user_exam.try(:user)
      if user
        user.activity!('question.rating', question: selected_answer.question, difficulty: selected_answer.difficulty.to_s, confidefault_points: DIFFICULTY_VOTE_POINTS) if selected_answer.difficulty.to_s.strip != ''
        user.activity!('question.confidence', question: selected_answer.question, confidence: selected_answer.confidence.to_s, selectdefault_points: CONFIDENCE_VOTE_POINTS) if selected_answer.confidence.to_s.strip != ''
      end
    end
  end
end
