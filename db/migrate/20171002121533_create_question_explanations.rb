class CreateQuestionExplanations < ActiveRecord::Migration[5.0]
  def change
    create_table :question_explanations do |t|
      t.references :user
      t.references :question
      t.string :locale
      t.text :body
    end
  end
end
