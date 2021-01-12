class CreateIntermediateTablesForPlaylistsAndAllContent < ActiveRecord::Migration[5.0]
  def change
    create_table :playlist_contents do |t|
      t.belongs_to :playlist, index: true
      t.belongs_to :link, index: true
      t.belongs_to :media, index: true
      t.belongs_to :conversation, index: true
      t.belongs_to :question, index: true
      t.integer :position, index: true
    end
  end
end


