class LinksSearchResult < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION links_search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        rank NUMERIC
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          SQL = 'SELECT id, ''links'' AS type, 0 AS rank
            FROM links';
        ELSE
          SQL = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM links_taggings_view, TO_TSQUERY(''' || p_search || ''') query
            WHERE query @@ textsearch';
        END IF;

        IF p_search IS NULL THEN
          SQL = SQL || ' ORDER BY 1 DESC';
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
    execute "DROP FUNCTION links_search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
