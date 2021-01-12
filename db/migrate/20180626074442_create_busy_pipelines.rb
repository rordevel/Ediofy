class CreateBusyPipelines < ActiveRecord::Migration[5.0]
  def change
    create_table :busy_pipelines do |t|
      t.string :pipeline_id
      t.string :job_id
      t.timestamps
    end
  end
end
