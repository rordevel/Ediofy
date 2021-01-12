class AddTitleToQuestionTaggingView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(
DROP VIEW IF EXISTS questions_taggings_view;
CREATE OR REPLACE VIEW questions_taggings_view AS
      SELECT
        q.id,
        COALESCE((STRING_AGG(t.name, ' ')), '') AS tags,
        TO_TSVECTOR(COALESCE((STRING_AGG(t.name || ' ' || q.title, ' ')), '')) AS textsearch,
        q.comments_count, q.votes_count , q.view_count, q.created_at, q.user_id
      FROM questions AS q
        LEFT JOIN taggings AS tg ON tg.taggable_type = 'Question' AND tg.taggable_id = q.id AND tg.context = 'tags'
        LEFT JOIN tags AS t ON t.id = tg.tag_id
      WHERE q.approved = TRUE AND q.status <> 2
      GROUP BY q.id
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS questions_taggings_view;"
  end
end
