if @question.errors.any?
  json.status FAIL_STATUS
  json.errors @question.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.question do
  json.(@question, :id, :user_id, :question_source_id, :difficulty, :question_image, :active, :approved, :score, :question_media_count, :private, :ancestry, :created_at, :updated_at)
  json.body truncate_html @question.body
  json.explanation truncate_html @question.explanation
  json.votes_up_count @question.count_votes_up
  json.votes_down_count @question.count_votes_down
end