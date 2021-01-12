class CreateSelectedAnswer < ActiveRecord::Migration[5.0]
  def change
    create_table :selected_answers do |t|
      t.references :answer
      t.boolean :not_sure, null: false, default: false
      t.string :answer_order
      t.string :difficulty
      t.string :confidence

      t.timestamps
    end
  end
end
