class AddGroupIdToContentViews < ActiveRecord::Migration[5.0]
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
        LEFT JOIN groups_links as gl ON gl.link_id = l.id
      WHERE l.deleted = FALSE AND u.is_active = true AND gl.group_id IS NULL
      GROUP BY l.id
    )

    self.connection.execute %Q(CREATE OR REPLACE VIEW media_taggings_view AS
      SELECT
        m.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || m.title, ' ')), '')) AS textsearch,
        m.comments_count, m.votes_count, m.view_count, m.created_at, m.user_id, mf.media_type
      FROM media AS m
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Media' AND tg.taggable_id = m.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
        LEFT JOIN media_files mf ON mf.media_id = m.id
        LEFT JOIN users as u ON u.id = m.user_id
        LEFT JOIN groups_media as gm ON gm.media_id = m.id
      WHERE m.deleted = FALSE AND u.is_active = true AND gm.group_id IS NULL
      GROUP BY m.id,mf.media_type
    )

    self.connection.execute %Q(CREATE OR REPLACE VIEW questions_taggings_view AS
      SELECT
        q.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || q.title, ' ')), '')) AS textsearch,
        q.comments_count, q.votes_count , q.view_count, q.created_at, q.user_id
      FROM questions AS q
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Question' AND tg.taggable_id = q.id AND tg.context = 'tags'
        LEFT JOIN tags AS t ON t.id = tg.tag_id
        LEFT JOIN users as u ON u.id = q.user_id
        LEFT JOIN groups_questions as gq ON gq.question_id = q.id
      WHERE q.approved = TRUE AND q.status <> 2 AND u.is_active = true AND gq.group_id IS NULL
      GROUP BY q.id
    )

    self.connection.execute %Q(CREATE OR REPLACE VIEW conversations_taggings_view AS
      SELECT
        c.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || c.title, ' ')), '')) AS textsearch,
        c.comments_count, c.votes_count, c.view_count, c.created_at,c.user_id
      FROM conversations AS c
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Conversation' AND tg.taggable_id = c.id AND tg.context = 'tags'
        LEFT JOIN tags AS t ON t.id = tg.tag_id
        LEFT JOIN users as u ON u.id = c.user_id
        LEFT JOIN conversations_groups as cg ON cg.conversation_id = c.id
      WHERE c.deleted = FALSE AND u.is_active = true AND cg.group_id IS NULL
      GROUP BY c.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS links_taggings_view;"
    self.connection.execute "DROP VIEW IF EXISTS media_taggings_view;"
    self.connection.execute "DROP VIEW IF EXISTS questions_taggings_view;"
    self.connection.execute "DROP VIEW IF EXISTS conversations_taggings_view;"
  end
end
