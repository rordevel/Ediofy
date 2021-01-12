class ConversationsTaggingsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW conversations_taggings_view AS
      SELECT
        c.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name, ' ')), '')) AS textsearch
      FROM conversations AS c
        INNER JOIN taggings AS tg ON tg.taggable_type = 'Conversation' AND tg.taggable_id = c.id AND tg.context = 'tags'
        INNER JOIN tags AS t ON t.id = tg.tag_id
      GROUP BY c.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS conversations_taggings_view;"
  end
end
