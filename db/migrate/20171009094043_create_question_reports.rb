class CreateQuestionReports < ActiveRecord::Migration[5.0]
  def change
    create_table :question_reports do |t|
      t.references :question
      t.references :user
      t.string :reason

      t.timestamps
    end
  end
end
