json.exam do
  json.(@user_exam, :id, :finished, :exam_mode)
  json.next_position @exam_question.lower_item.blank? ? nil : @exam_question.lower_item.position
  json.question do
    json.(@question, :id)
    json.body @question.body.try(:html_safe)
    json.translation_available @question.translation_available?(current_user)
    json.selected_answer (@selected_answer.present? && @selected_answer.persisted?) ? @selected_answer : false
    json.answers @answers
  end
end