if @exam.errors.any?
  json.status FAIL_STATUS
  json.errors @exam.errors.full_messages
else
  json.status SUCCESS_STATUS
end
json.exam do
  json.(@exam, :id, :finished)
  json.exam_mode @exam.exam_mode
  json.question do
    json.(@question, :id)
    json.body @question.body.try(:html_safe)
    json.translation_available @question.translation_available?(current_user)
    json.selected_answer (@selected_answer.present? && @selected_answer.persisted?) ? @selected_answer : false
    json.answers @answers
  end
end