class CreateExamQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_exam_questions do |t|
      t.references :user_exam
      t.references :question
      t.integer :position, null: false, default: 1
      t.string :user_exam_type
      t.integer :selected_answer_id

      t.timestamps
    end
  end
end
