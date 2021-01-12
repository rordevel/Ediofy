if @media_report.errors.any?
  json.status FAIL_STATUS
  json.errors @media_report.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.media_report @media_report