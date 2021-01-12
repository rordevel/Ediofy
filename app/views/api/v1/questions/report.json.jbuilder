if @question_report.errors.any?
  json.status FAIL_STATUS
  json.errors @question_report.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.question_report @question_report