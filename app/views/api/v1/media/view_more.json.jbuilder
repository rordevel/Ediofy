if @media.errors.any?
  json.status FAIL_STATUS
  json.errors @media.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.media do
  json.(@media, :id)
  if user_signed_in?
    @comments = @media.comments.for current_user
  else
    @comments = @comments=@media.comments.approved
  end
  json.comments @comments
  ids = @comments.select(:id)
  json.comment_references Reference.joins(:comment).where(referenceable_id: ids, comments: {status: 'approved'}).limit(5)
  json.questions @media.questions.active.approved
end