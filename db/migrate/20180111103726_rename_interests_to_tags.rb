class RenameInterestsToTags < ActiveRecord::Migration[5.0]
  def change
  	drop_table :interests
  	rename_table :interest_questions, :tag_questions
  	rename_table :ediofy_user_exams_interests, :ediofy_user_exams_tags
  	
  	rename_column :tag_questions, :interest_id, :tag_id
  	rename_column :ediofy_user_exams_tags, :interest_id, :tag_id
  	rename_column :settings, :interest_choice, :tag_choice
  end
end
