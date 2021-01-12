class RecentlyViewedTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION recently_viewed_total(p_user_id INTEGER)
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
        tags TEXT;
      BEGIN
        SQL = 'SELECT tags
          FROM users_taggings_view
          WHERE context=''histories'' AND id = ' || p_user_id || ' LIMIT 1';

        FOR ROW IN EXECUTE SQL LOOP
          tags := ROW.tags::TEXT;
        END LOOP;

        IF tags != '' THEN
          SQL_CONTRIBUTORS = 'SELECT ''contributors'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM users_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE context=''tags'' AND query @@ textsearch
            ) AS record';

          SQL_CONVERSATIONS = 'SELECT ''conversations'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM conversations_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_MEDIA = 'SELECT ''media'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM media_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_QUESTOINS = 'SELECT ''questions'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM questions_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL_LINKS = 'SELECT ''links'' AS type, COUNT(*) AS total
            FROM (
              SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM links_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE query @@ textsearch
            ) AS record';

          SQL = 'SELECT SUM(record.total) AS total FROM
            (
              (' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ')  UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')
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
    execute "DROP FUNCTION recently_viewed_total(p_user_id INTEGER)";
  end
end
