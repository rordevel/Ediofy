class RenameTopicsToInterests < ActiveRecord::Migration[5.0]
  def change
  	rename_table :topics, :interests
  	rename_table :topic_questions, :interest_questions
  	rename_table :ediofy_user_exams_topics, :ediofy_user_exams_interests
  	
  	rename_column :interest_questions, :topic_id, :interest_id
  	rename_column :ediofy_user_exams_interests, :topic_id, :interest_id
  	rename_column :settings, :topic_choice, :interest_choice
  end
end
