class AddJobIdToMediaFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :media_files, :job_id, :string
  end
end
