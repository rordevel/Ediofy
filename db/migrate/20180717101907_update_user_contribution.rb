class UpdateUserContribution < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS user_contributions(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR);
    CREATE OR REPLACE FUNCTION user_contributions(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_profile BOOLEAN, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        comments_count INTEGER,
        votes_count INTEGER,
        view_count INTEGER
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_CONTRIBUTORS TEXT;
        SQL_CONVERSATIONS TEXT;
        SQL_MEDIA TEXT;
        SQL_QUESTOINS TEXT;
        SQL_LINKS TEXT;
        SQL TEXT;
      BEGIN
        IF p_profile = true THEN
          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM conversations
            WHERE user_id = ' || p_user_id || ' AND  private = FALSE';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM media
            WHERE user_id = ' || p_user_id || ' AND  private = FALSE';

          SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM questions
            WHERE user_id = ' || p_user_id || ' AND approved = TRUE AND status <> 2 AND  private = FALSE';

          SQL_LINKS = 'SELECT id, ''links'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM links
            WHERE user_id = ' || p_user_id || ' AND  private = FALSE';
        ELSE
          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM conversations
            WHERE user_id = ' || p_user_id;

          SQL_MEDIA = 'SELECT id, ''media'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM media
            WHERE user_id = ' || p_user_id;

          SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM questions
            WHERE user_id = ' || p_user_id || ' AND approved = TRUE AND status <> 2';

          SQL_LINKS = 'SELECT id, ''links'' AS type, 0 AS rank, comments_count, votes_count, view_count, created_at
            FROM links
            WHERE user_id = ' || p_user_id;
        END IF;

        SQL = '(' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')';
        IF p_sort = 'latest' THEN
          SQL = SQL || ' ORDER BY created_at DESC';
        ELSIF p_sort = 'top_rated' THEN
          SQL = SQL || ' ORDER BY votes_count DESC';
        ELSIF p_sort = 'most_popular' THEN
          SQL = SQL || ' ORDER BY comments_count DESC';
        ELSIF p_sort = 'trending' THEN
          SQL = SQL || ' ORDER BY view_count DESC';
        END IF;

        SQL = SQL || ' LIMIT ' || p_limit || ' OFFSET ' || p_offset || '';

        FOR ROW IN EXECUTE SQL LOOP
          id := row.id::INTEGER;
          type := row.type::TEXT;
          comments_count := row.id::INTEGER;
          votes_count := row.id::INTEGER;
          view_count := row.id::INTEGER;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION user_contributions(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
