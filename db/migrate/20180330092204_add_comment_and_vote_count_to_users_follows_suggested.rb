class AddCommentAndVoteCountToUsersFollowsSuggested < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS users_follows_suggested(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR);
    CREATE OR REPLACE FUNCTION users_follows_suggested(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER DEFAULT 0, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        rank NUMERIC,
        comments_count INTEGER,
        votes_count INTEGER,
        view_count INTEGER
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        tags TEXT;
      BEGIN
       IF p_user_id = 0 THEN
        SQL = 'SELECT tags
          FROM users_taggings_view
          WHERE context=''interests'' LIMIT 1';
       ELSE
        SQL = 'SELECT tags
          FROM users_taggings_view
          WHERE context=''interests'' AND id = ' || p_user_id || '
          LIMIT 1';
       END IF;


        FOR ROW IN EXECUTE SQL LOOP
          tags := ROW.tags::TEXT;
        END LOOP;

        IF tags != '' THEN
          SQL = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM users_taggings_view, TO_TSQUERY(''' || replace(tags, ' ', '|') || ''') query
            WHERE context=''interests'' AND id != ' || p_user_id || ' AND query @@ textsearch';

        IF p_sort = 'latest' THEN
          SQL = SQL || ' ORDER BY created_at DESC';
        ELSIF p_sort = 'top_rated' THEN
          SQL = SQL || ' ORDER BY votes_count DESC';
        ELSIF p_sort = 'most_popular' THEN
          SQL = SQL || ' ORDER BY comments_count DESC';
        ELSIF p_sort = 'trending' THEN
          SQL = SQL || ' ORDER BY view_count DESC';
        END IF;
          SQL = SQL || ' LIMIT ' || p_limit || ' OFFSET ' || p_offset || '';

          FOR ROW IN EXECUTE SQL LOOP
            id := row.id::INTEGER;
            type := row.type::TEXT;
            rank := row.rank::NUMERIC;
            comments_count := row.id::INTEGER;
            votes_count := row.id::INTEGER;
            view_count := row.id::INTEGER;
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
