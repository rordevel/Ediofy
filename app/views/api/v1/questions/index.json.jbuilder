json.status SUCCESS_STATUS
json.questions do
  json.array! @questions do |question|
    json.(
      question,
      :id, :user_id, :question_source_id, :difficulty, :question_image, :active, :approved, :score, :question_media_count, :private, :ancestry, :created_at, :updated_at
    )
    json.body truncate_html question.body
    json.explanation truncate_html question.explanation
  end
end