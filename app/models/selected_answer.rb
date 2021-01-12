class SelectedAnswer < ActiveRecord::Base

  DIFFICULTY = [
    :easy,
    :medium,
    :hard
  ]

  CONFIDENCE = [
    :low,
    :medium,
    :high
  ]

  scope :not_sure, -> { where(not_sure: true) }
  scope :sure, -> { where(not_sure: false) }

  after_save :touch_user_exam

  belongs_to :answer
  has_one :user_exam_question
  has_one :question, through: :answer

  validates :answer, presence: true
  validate  :ensure_saving_answer_allowed

  delegate :correct?, to: :answer

  after_create :create_activity

  def self.correct
    joins{answer}.where{answer.correct.eq true}
  end

  protected

  # Revisions allow answers to be created but not altered
  # Mock exams that are active allow answer creation and updating answers
  # Finished or expired mock exams do not allow answer creating or updating answers.
  def ensure_saving_answer_allowed
    if user_exam_question.try(:user_exam).present?

      # If we're on a mock exam and the timer is finished (or the exam is set to finished)
      # Then new answers cannot be submitted and existing cannot be updated
      if user_exam_question.user_exam.finished?
        errors.add(:base, :answer_already_selected) if new_record? || changes.present?
      end

    end
  end

  def touch_user_exam
    user_exam_question.try(:user_exam).try(:touch)
  end

  def create_activity
    user = user_exam_question&.user_exam&.user

    if user && user != question.user
      if correct?
        user.activity! 'question.answer.correct', question: question, default_points: correct_answer_points, cpd_time: correct_answer_cpd_time
      else
        user.activity! 'question.answer.wrong', question: question, cpd_time: wrong_answer_cpd_time
      end
    end
  end

  private

  def correct_answer_points
    ActivityKeyPointValue.find_by(activity_key: 'question.answer.correct')&.point_value
  end

  def correct_answer_cpd_time
    ActivityKeyPointValue.find_by(activity_key: 'question.answer.correct')&.cpd_time
  end

  def wrong_answer_cpd_time
    ActivityKeyPointValue.find_by(activity_key: 'question.answer.wrong')&.cpd_time
  end
end
