class RemoveRankFromQuestionsSearchResult < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS questions_search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR);
    CREATE OR REPLACE FUNCTION questions_search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
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
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          SQL = 'SELECT id, ''questions'' AS type, 0 AS rank, comments_count, votes_count, view_count
            FROM questions
            WHERE approved = TRUE AND status <> 2';
        ELSE
          SQL = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM questions_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE query @@ textsearch';
        END IF;

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
    execute "DROP FUNCTION IF EXISTS questions_search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
