if @media.errors.any?
  json.status FAIL_STATUS
  json.errors @media.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.media @media