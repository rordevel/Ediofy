class RemoveExtraTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :media_reports
    drop_table :question_reports
  end
end
