class AddTitleAndCountToMediaTaggingView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW media_taggings_view AS
      SELECT
        m.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || m.title, ' ')), '')) AS textsearch,
        m.comments_count, m.votes_count, m.view_count, m.created_at
      FROM media AS m
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Media' AND tg.taggable_id = m.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
      WHERE m.private = FALSE
      GROUP BY m.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS media_taggings_view;"
  end
end
