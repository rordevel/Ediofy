class AddBlockedAndFollowingIdsParamToSearchResult < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR);
    CREATE OR REPLACE FUNCTION search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest',p_blocked_ids VARCHAR DEFAULT NULL, p_following_ids VARCHAR DEFAULT NULL, p_tags VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        id INTEGER,
        type VARCHAR,
        comments_count INTEGER,
        votes_count INTEGER,
        view_count INTEGER
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_CONTRIBUTORS TEXT;
        SQL_CONVERSATIONS TEXT;
        SQL_MEDIA TEXT;
        SQL_QUESTIONS TEXT;
        SQL_LINKS TEXT;
        SQL TEXT;
        blocked_ids INTEGER[];
        following_ids INTEGER[];
      BEGIN
        blocked_ids = coalesce(string_to_array(p_blocked_ids,',')::integer[], array[]::int[]);
        following_ids = coalesce(string_to_array(p_following_ids,',')::integer[], array[]::int[]);
        IF p_search IS NULL THEN
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, 0 AS rank, created_at
          --   FROM users
          --   WHERE ediofy_terms_accepted = true AND profile_completed = true';

          -- SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank, created_at, comments_count, votes_count, view_count
          --  FROM conversations WHERE deleted = FALSE AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM conversations_taggings_view, TO_TSQUERY(''' || p_tags || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM media_taggings_view, TO_TSQUERY(''' || p_tags || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_QUESTIONS = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM questions_taggings_view, TO_TSQUERY(''' || p_tags || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_LINKS = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM links_taggings_view, TO_TSQUERY(''' || p_tags || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

        ELSE
          -- SQL_CONTRIBUTORS = 'SELECT id, ''contributors'' AS type, TS_RANK_CD(textsearch, query) AS rank
          --   FROM users_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
          --   WHERE context=''interests'' AND query @@ textsearch AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM conversations_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_MEDIA = 'SELECT id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM media_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_QUESTIONS = 'SELECT id, ''questions'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM questions_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_LINKS = 'SELECT id, ''links'' AS type, TS_RANK_CD(textsearch, query) AS rank, comments_count, votes_count, view_count, created_at
            FROM links_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

        END IF;

        -- SQL = '(' || SQL_CONTRIBUTORS || ') UNION (' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTIONS || ') UNION (' || SQL_LINKS || ')';
        SQL = '(' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTIONS || ') UNION (' || SQL_LINKS || ')';

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
          comments_count := row.comments_count::INTEGER;
          votes_count := row.votes_count::INTEGER;
          view_count := row.view_count::INTEGER;

          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS search_results(p_limit INTEGER, p_offset INTEGER, p_search VARCHAR, p_sort VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR);";
  end
end
