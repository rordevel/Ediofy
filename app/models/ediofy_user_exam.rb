class EdiofyUserExam < ActiveRecord::Base
  include Examable

  UNFINISHED_STATE = 'unfinished'
  FINISHED_STATE   = 'finished'
  EXAM_MODES = {
    0 => "Shuffle",
    1 => "One Question",
    5 => "Five Question",
    10 => "Ten Question",
    20 => "Twenty Question"
  }

  has_many :reports, as: :reportable
  acts_as_votable cacheable_strategy: :update_columns
  acts_as_taggable

  before_validation :question_reset, on: :create
  before_validation :build_questions, on: :create

  validates :exam_questions, presence: true # removed tags validation

  validates :exam_mode, inclusion: { in: EXAM_MODES.keys, message: "Revision type is not included in the list" }

  # Provides functions:
  # - shuffle_mode?
  # - one_question_mode?
  # - five_question_mode?
  # - ten_question_mode?
  # - twenty_question_mode?
  EXAM_MODES.each do |key,txt|
    define_method "#{txt.parameterize}_mode?" do
      exam_mode == key
    end
  end

  def first_exam?
    current_user.ediofy_user_exams.count == 1
  end

  def title
    tags.map(&:title).join(',')
  end

  # Status for display, e.g.: "Unfinished Tag", "Unfinished Subject"
  def display_status
    exam_state = (all_questions_answered? ? FINISHED_STATE : UNFINISHED_STATE).titleize
    "#{exam_state} Subject"
  end

  def question_pool
    correctly_selected_answers = SelectedAnswer.joins(question:[user_exam_questions:[:ediofy_user_exam]]).where("selected_answers.created_at > ?", user.setting.question_reset_date || user.created_at).where( answers: { correct: true }, ediofy_user_exams: { user_id: user.id } )
    correctly_answered_questions = Question.active.where(id: correctly_selected_answers.select("questions.id")).all

    # Needs to be assigned to something other than tags so squeel stops thinking it's a table called tags
    exam_tags=tags
    question_pool = Question.joins(:tag_questions).where("tag_questions.tag_id": exam_tags.collect(&:id), active: true).uniq
    exam_question_pool = question_pool - correctly_answered_questions

    unless shuffle_mode?
      exam_question_pool = exam_question_pool.sample(exam_mode.to_i) unless exam_question_pool.count == 0
    end

    # When the user has answered all the questions correct and there IS questions
    # we need to add a question reset date so that future checks for correctly answered questions
    # only include this "session"
    #
    # Regardless of question_reset setting, if the user has no more questions we need to reset.
    #
    # There's a possibility of resetting early when the user just doesn't have questions to answer
    # in this set of tags, this issue needs to be handled gracefully.
    # TODO: read above & fix.
    if exam_question_pool.empty? && question_pool.present?
      user.setting.update_attribute(:question_reset_date, DateTime.now)

      exam_question_pool = question_pool
    end
    exam_question_pool
  end

  def build_questions
    if tags.present? && exam_questions.empty?

      question_pool.each do |question|
        exam_questions.build(question: question)
      end

    end
  end

  def paginated_questions page
    # default to page 1 if the page number is not within the expected page range
    page = page.to_i
    page = 1 unless (1..max_page_number).to_a.include?(page)

    UserExamQuestion.where(exam_id: self.id, exam_type: self.class.to_s).order(:position).page page
  end

  def max_page_number
    per_page = UserExamQuestion::PER_PAGE
    num_questions = exam_questions.count

    mod = num_questions % per_page
    if mod == 0
      ((num_questions - mod) / per_page)
    else
      ((num_questions - mod) / per_page) + 1
    end
  end

protected

  def question_reset
    if user.present? && user.setting.present?
      if user.setting.question_reset == :monthly
        if user.setting.question_reset_date + 1.month < DateTime.now
          user.setting.update_attribute(:question_reset_date, DateTime.now)
        end
      end
    end
  end  
end