class RecentlyViewed < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION recently_viewed(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        rank NUMERIC
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
          SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM users_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE context=''tags'' AND query @@ textsearch';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM conversations_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE query @@ textsearch';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM media_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE query @@ textsearch';

          SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM questions_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE query @@ textsearch';

          SQL_LINKS = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank
            FROM links_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE query @@ textsearch';

          SQL = '(' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')';

          SQL = SQL || ' ORDER BY rank DESC';

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
    execute "DROP FUNCTION recently_viewed(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_sort VARCHAR)";
  end
end
