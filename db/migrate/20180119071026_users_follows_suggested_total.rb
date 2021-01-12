class UsersFollowsSuggestedTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_follows_suggested_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
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
          FROM users_taggings_view
          WHERE context=''interests'' AND id = ' || p_user_id || ' LIMIT 1';

        FOR ROW IN EXECUTE SQL LOOP
          tags := ROW.tags::TEXT;
        END LOOP;

        IF tags != '' THEN
          SQL = 'SELECT COUNT(*) AS total
            FROM (
              SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM users_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
              WHERE context=''interests'' AND id != ' || p_user_id || ' AND query @@ textsearch
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
    execute "DROP FUNCTION users_follows_suggested_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
