class CreateExams < ActiveRecord::Migration[5.0]
  def change
    create_table :ediofy_user_exams do |t|
      t.references :user
      t.integer :exam_mode
      t.boolean :finished, default: false

      t.timestamps
    end
    create_table :ediofy_user_exams_topics do |t|
      t.references :ediofy_user_exam
      t.references :topic
    end
  end
end
