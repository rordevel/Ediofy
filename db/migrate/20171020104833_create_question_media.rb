class CreateQuestionMedia < ActiveRecord::Migration[5.0]
  def change
    create_table :media_questions do |t|
      t.references :media, null: false
      t.references :question, null: false
    end
    add_index :media_questions, [:question_id, :media_id], unique: true
    add_index :media_questions, [:media_id, :question_id]
  end
end
