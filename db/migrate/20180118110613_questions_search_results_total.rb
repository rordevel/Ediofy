class QuestionsSearchResultsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION questions_search_results_total(p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          SQL = 'SELECT COUNT(*) AS total
            FROM questions
            WHERE approved = TRUE AND status <> 2';
        ELSE
          SQL = 'SELECT COUNT(*) AS total
            FROM (
              SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM questions_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE query @@ textsearch
            ) AS record';
        END IF;

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION questions_search_results_total(p_search VARCHAR)";
  end
end
