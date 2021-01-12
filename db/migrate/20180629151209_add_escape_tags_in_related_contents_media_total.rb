class AddEscapeTagsInRelatedContentsMediaTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION related_contents_media_total(p_id INTEGER, p_type VARCHAR, p_return_type VARCHAR)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        tags TEXT;
      BEGIN
        SQL = 'SELECT tags
          FROM ' || p_type || '_taggings_view
          WHERE id = ' || p_id || ' LIMIT 1';

        FOR ROW IN EXECUTE SQL LOOP
          tags := REPLACE(ROW.tags::TEXT,'''','''''');
        END LOOP;

        IF tags != '' THEN
          SQL = 'SELECT COUNT(*) AS total
            FROM (
              (
                SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
                FROM media_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
                WHERE query @@ textsearch';

              IF p_type = 'media' THEN
                SQL = SQL || ' AND id != ' || p_id;
              END IF;

          SQL = SQL || '
              )
              UNION
              (
                SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
                FROM links_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
                WHERE query @@ textsearch';

              IF p_type = 'links' THEN
                SQL = SQL || ' AND id != ' || p_id;
              END IF;

          SQL = SQL || '
              )
            ) AS record';

          FOR ROW IN EXECUTE SQL LOOP
            total := row.total;
            RETURN NEXT;
          END LOOP;
        END IF;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION related_contents_media_total(p_id INTEGER, p_type VARCHAR, p_return_type VARCHAR)";
  end
end
