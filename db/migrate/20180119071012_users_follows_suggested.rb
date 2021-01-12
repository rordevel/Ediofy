class UsersFollowsSuggested < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_follows_suggested(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        rank NUMERIC
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        tags TEXT;
      BEGIN
        SQL = 'SELECT tags
          FROM users_taggings_view
          WHERE context=''interests'' AND id = ' || p_user_id || '
          LIMIT 1';

        FOR ROW IN EXECUTE SQL LOOP
          tags := ROW.tags::TEXT;
        END LOOP;

        IF tags != '' THEN
          SQL = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM users_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE context=''interests'' AND id != ' || p_user_id || ' AND query @@ textsearch
            ORDER BY rank DESC';

          SQL = SQL || ' LIMIT ' || p_limit || ' OFFSET ' || p_offset || '';

          FOR ROW IN EXECUTE SQL LOOP
            id := row.id::INTEGER;
            type := row.type::TEXT;
            rank := row.rank::NUMERIC;

            RETURN NEXT;
          END LOOP;
        END IF;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION users_follows_suggested(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
