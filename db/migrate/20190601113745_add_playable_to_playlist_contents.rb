class AddPlayableToPlaylistContents < ActiveRecord::Migration[5.1]
  def change
    add_reference :playlist_contents, :playable, polymorphic: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE playlist_contents
          SET
            playable_type = CASE
              WHEN conversation_id IS NOT NULL THEN 'Conversation'
              WHEN link_id IS NOT NULL THEN 'Link'
              WHEN media_id IS NOT NULL THEN 'Media'
              WHEN question_id IS NOT NULL THEN 'Question'
            END,
            playable_id = COALESCE(conversation_id, link_id, media_id, question_id)
        SQL
      end

      dir.down do
        execute <<-SQL
          UPDATE playlist_contents
          SET
            conversation_id = CASE WHEN playable_type = 'Conversation' THEN playable_id ELSE NULL END,
            link_id = CASE WHEN playable_type = 'Link' THEN playable_id ELSE NULL END,
            media_id = CASE WHEN playable_type = 'Media' THEN playable_id ELSE NULL END,
            question_id = CASE WHEN playable_type = 'Question' THEN playable_id ELSE NULL END
        SQL
      end
    end

    remove_index :playlist_contents, :link_id
    remove_index :playlist_contents, :media_id
    remove_index :playlist_contents, :conversation_id
    remove_index :playlist_contents, :question_id

    remove_column :playlist_contents, :question_id, :integer
    remove_column :playlist_contents, :conversation_id, :integer
    remove_column :playlist_contents, :media_id, :integer
    remove_column :playlist_contents, :link_id, :integer
  end
end
