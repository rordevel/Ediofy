class SearchResults < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        rank NUMERIC
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
        IF p_search IS NULL THEN
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, 0 AS rank, created_at
          --   FROM users
          --   WHERE ediofy_terms_accepted = true AND profile_completed = true';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank, created_at
            FROM conversations';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, 0 AS rank, created_at
            FROM media
            WHERE  private = FALSE';

          SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, 0 AS rank, created_at
            FROM questions
            WHERE approved = TRUE AND status <> 2';

          SQL_LINKS = 'SELECT id, ''links'' AS type, 0 AS rank, created_at
            FROM links';

        ELSE
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
          --   FROM users_taggings_view, TO_TSQUERY(''' || p_search || ''') query
          --   WHERE context=''interests'' AND query @@ textsearch';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM conversations_taggings_view, TO_TSQUERY(''' || p_search || ''') query
            WHERE query @@ textsearch';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM media_taggings_view, TO_TSQUERY(''' || p_search || ''') query
            WHERE query @@ textsearch';

          SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM questions_taggings_view, TO_TSQUERY(''' || p_search || ''') query
            WHERE query @@ textsearch';

          SQL_LINKS = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM links_taggings_view, TO_TSQUERY(''' || p_search || ''') query
            WHERE query @@ textsearch';

        END IF;

        -- SQL = '(' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')';
        SQL = '(' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')';

        IF p_search IS NULL THEN
          SQL = SQL || ' ORDER BY created_at DESC';
        ELSE
          SQL = SQL || ' ORDER BY rank DESC';
        END IF;

        SQL = SQL || ' LIMIT ' || p_limit || ' OFFSET ' || p_offset || '';

        FOR ROW IN EXECUTE SQL LOOP
          id := row.id::INTEGER;
          type := row.type::TEXT;
          rank := row.rank::NUMERIC;

          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
