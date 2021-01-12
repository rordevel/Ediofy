class RemoveTagQuestions < ActiveRecord::Migration[5.0]
  def change
  	drop_table :tag_questions
  	drop_table :ediofy_user_exams_tags
  end
end
