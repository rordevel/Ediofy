class AddFullNameToUserTaggingView < ActiveRecord::Migration[5.0]
  class AddTitleAndCountToUserTaggingView < ActiveRecord::Migration[5.0]
    def up
      self.connection.execute %Q(CREATE OR REPLACE VIEW users_taggings_view AS
      SELECT
        u.id, tg.context,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || u.full_name, ' ')), '')) AS textsearch,
        u.comments_count, u.votes_count, u.view_count, u.created_at
      FROM users AS u
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'User' AND tg.taggable_id = u.id
        LEFT JOIN tags AS t ON t.id = tg.tag_id
      WHERE u.ediofy_terms_accepted = true AND u.profile_completed = true
      GROUP BY u.id, tg.context
    )
    end

    def down
      self.connection.execute "DROP VIEW IF EXISTS users_taggings_view;"
    end
  end

end
