if @exam_question.errors.any?
  json.status FAIL_STATUS
  json.errors @exam_question.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.exam_question @exam_question
json.next_question @exam_question.next_unanswered
json.shuffle_mode @user_exam.shuffle_mode?
json.one_question_mode @user_exam.one_question_mode?
json.user_exam @user_exam