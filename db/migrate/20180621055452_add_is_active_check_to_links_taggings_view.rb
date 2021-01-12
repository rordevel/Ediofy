class AddIsActiveCheckToLinksTaggingsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW links_taggings_view AS
      SELECT
        l.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || l.title, ' ')), '')) AS textsearch,
        l.comments_count, l.votes_count, l.view_count, l.created_at, l.user_id
      FROM links AS l
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Link' AND tg.taggable_id = l.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
        LEFT JOIN users as u ON u.id = l.user_id
      WHERE l.deleted = FALSE AND u.is_active = true
      GROUP BY l.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS links_taggings_view;"
  end
end
