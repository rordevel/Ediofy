class CreateTopicQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :topic_questions do |t|
      t.references :topic
      t.references :question
    end
  end
end
