class SearchResultsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION search_results_total(p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
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
          -- SQL_CONTRIBUTORS = 'SELECT COUNT(*) AS total
          --   FROM users
          --   WHERE ediofy_terms_accepted = true AND profile_completed = true';

          SQL_CONVERSATIONS = 'SELECT COUNT(*) AS total
            FROM conversations';

          SQL_MEDIA = 'SELECT COUNT(*) AS total
            FROM media
            WHERE  private = FALSE';

          SQL_QUESTOINS = 'SELECT COUNT(*) AS total
            FROM questions
            WHERE approved = TRUE AND status <> 2';

          SQL_LINKS = 'SELECT COUNT(*) AS total
            FROM links';

        ELSE
          -- SQL_CONTRIBUTORS = 'SELECT ''contributors'' AS type, COUNT(*) AS total
          --   FROM (
          --     SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
          --     FROM users_taggings_view, TO_TSQUERY(''' || p_search || ''') query
          --     WHERE context=''interests'' AND query @@ textsearch
          --   ) AS record';

          SQL_CONVERSATIONS = 'SELECT ''conversations'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM conversations_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_MEDIA = 'SELECT ''media'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM media_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_QUESTOINS = 'SELECT ''questions'' AS type,COUNT(*) AS total
            FROM (
              SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM questions_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_LINKS = 'SELECT ''links'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM links_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE query @@ textsearch
            ) AS record';

        END IF;

        -- SQL = 'SELECT SUM(record.total) AS total FROM
        --   (
        --     (' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ')  UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')
        --   ) AS record';
        SQL = 'SELECT SUM(record.total) AS total FROM
          (
            (' || SQL_CONVERSATIONS || ')  UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')
          ) AS record';

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION search_results_total(p_search VARCHAR)";
  end
end
