if @exam.errors.any?
  json.status FAIL_STATUS
  json.errors @exam.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.exam @exam