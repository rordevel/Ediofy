class SearchUsingTaggingViewInUsersSearchResultTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_search_results_total(p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          SQL = 'SELECT COUNT(DISTINCT id) AS total
            FROM users_taggings_view
            WHERE context=''interests''';
        ELSE
          SQL = 'SELECT COUNT(*) AS total
            FROM (
              SELECT DISTINCT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM users_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              WHERE context=''interests'' AND query @@ textsearch
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
    execute "DROP FUNCTION users_search_results_total(p_search VARCHAR)";
  end
end
