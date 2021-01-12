module Ediofy::ExamHelper

 def answer_progress_class(selected_answer, answer)
    if answer.correct?
      'correct'
    end
  end

  def answer_label(index)
    ("A".."Z").to_a[index]
  end

  def remaining_time(member_mock_exam)
    seconds = seconds_left member_mock_exam

    hours, seconds = seconds.divmod 3600
    minutes, seconds = seconds.divmod 60

    "%02d:%02d:%02d" % [hours, minutes, seconds]
  end

  def seconds_left(member_mock_exam)
    current_time     = (member_mock_exam.paused_at || Time.now).to_f
    seconds_remaning = (member_mock_exam.end_time.to_f - current_time)
    [0, seconds_remaning.floor].max
  end

  def time_percentage(member_mock_exam)
    total_seconds      = member_mock_exam.mock_exam.duration_in_minutes.minutes
    current_time       = (member_mock_exam.paused_at || Time.now).to_f
    seconds_remaning   = (member_mock_exam.end_time.to_f - current_time)
    seconds_progressed = total_seconds - seconds_remaning
    progress           = [1, (seconds_progressed.to_f / total_seconds.to_f)].min
    number_to_percentage(progress * 100.0, precision: 1)
  end

end