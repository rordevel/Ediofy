class RemoveFollowingWhenSearchParamProvidedFromMediaSearchResultsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS media_search_results_total(p_search VARCHAR);
      DROP FUNCTION IF EXISTS media_search_results_total(p_search VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR);
    CREATE OR REPLACE FUNCTION media_search_results_total(p_search VARCHAR DEFAULT NULL,p_blocked_ids VARCHAR DEFAULT NULL, p_following_ids VARCHAR DEFAULT NULL, p_tags VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        blocked_ids INTEGER[];
        following_ids INTEGER[];
      BEGIN
        blocked_ids = coalesce(string_to_array(p_blocked_ids,',')::integer[], array[]::int[]);
        following_ids = coalesce(string_to_array(p_following_ids,',')::integer[], array[]::int[]);
        IF p_search IS NULL THEN
          -- SQL = 'SELECT COUNT(*) AS total
          --  FROM media WHERE deleted = FALSE';
          SQL = 'SELECT count(*) as total
            FROM media_taggings_view, TO_TSQUERY(''' || p_tags || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';
        ELSE
          -- SQL = 'SELECT COUNT(*) AS total
          --  FROM (
          --    SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
          --    FROM media_taggings_view, TO_TSQUERY(''' || p_search || ''') query
          --    WHERE query @@ textsearch
          --  ) AS record';
          SQL = 'SELECT count(*) as total
            FROM media_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';
        END IF;

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS media_search_results_total(p_search VARCHAR)";
    execute "DROP FUNCTION IF EXISTS media_search_results_total(p_search VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR)";
  end
end
