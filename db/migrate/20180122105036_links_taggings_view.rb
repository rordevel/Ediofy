class LinksTaggingsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW links_taggings_view AS
      SELECT
        l.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name, ' ')), '')) AS textsearch
      FROM links AS l
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Link' AND tg.taggable_id = l.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
      GROUP BY l.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS links_taggings_view;"
  end
end
