class AddDeletedFalseToSearchResults < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR);
    CREATE OR REPLACE FUNCTION search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
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
        SQL_QUESTIONS TEXT;
        SQL_LINKS TEXT;
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, 0 AS rank, created_at
          --   FROM users
          --   WHERE ediofy_terms_accepted = true AND profile_completed = true';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank, created_at, comments_count, votes_count, view_count
            FROM conversations WHERE deleted = FALSE';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, 0 AS rank, created_at, comments_count, votes_count, view_count
            FROM media WHERE deleted = FALSE';

          SQL_QUESTIONS = 'SELECT id, ''questions'' AS type, 0 AS rank, created_at, comments_count, votes_count, view_count
            FROM questions
            WHERE approved = TRUE AND deleted = FALSE AND status <> 2';

          SQL_LINKS = 'SELECT id, ''links'' AS type, 0 AS rank, created_at, comments_count, votes_count, view_count
            FROM links WHERE deleted = FALSE';

        ELSE
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
          --   FROM users_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
          --   WHERE context=''interests'' AND query @@ textsearch';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM conversations_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE query @@ textsearch';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM media_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE query @@ textsearch';

          SQL_QUESTIONS = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM questions_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE query @@ textsearch';

          SQL_LINKS = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM links_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE query @@ textsearch';

        END IF;

        -- SQL = '(' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTIONS || ') UNION (' || SQL_LINKS || ')';
        SQL = '(' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTIONS || ') UNION (' || SQL_LINKS || ')';

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
          comments_count := row.comments_count::INTEGER;
          votes_count := row.votes_count::INTEGER;
          view_count := row.view_count::INTEGER;

          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR);";
  end
end
