class GroupsTaggingsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW groups_taggings_view AS
      SELECT
        l.id,
        l.comments_count,
        l.votes_count,
        l.view_count,
        l.created_at,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(l.title, ' ')), '')) AS textsearch
      FROM groups AS l
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Group' AND tg.taggable_id = l.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
      GROUP BY l.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS groups_taggings_view;"
  end
end
