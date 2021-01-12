class AddGroupToSearchResultsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS  search_results_total(p_search VARCHAR);
DROP FUNCTION IF EXISTS search_results_total(p_search VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR);
    CREATE OR REPLACE FUNCTION search_results_total(p_search VARCHAR DEFAULT NULL,p_blocked_ids VARCHAR DEFAULT NULL, p_following_ids VARCHAR DEFAULT NULL, p_tags VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_CONTRIBUTORS TEXT;
        SQL_CONVERSATIONS TEXT;
        SQL_MEDIA TEXT;
        SQL_QUESTIONS TEXT;
        SQL_LINKS TEXT;
        SQL_GROUPS TEXT;
        SQL TEXT;
        blocked_ids INTEGER[];
        following_ids INTEGER[];
      BEGIN
        blocked_ids = coalesce(string_to_array(p_blocked_ids,',')::integer[], array[]::int[]);
        following_ids = coalesce(string_to_array(p_following_ids,',')::integer[], array[]::int[]);
        IF p_search IS NULL THEN

          SQL_CONVERSATIONS = 'SELECT count(*) as total
            FROM conversations_taggings_view, TO_TSQUERY(''' || REPLACE(p_tags,'''','''''') || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_MEDIA = 'SELECT count(*) as total
            FROM media_taggings_view, TO_TSQUERY(''' || REPLACE(p_tags,'''','''''') || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_QUESTIONS = 'SELECT count(*) as total
            FROM questions_taggings_view, TO_TSQUERY(''' || REPLACE(p_tags,'''','''''') || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_LINKS = 'SELECT count(*) as total
            FROM links_taggings_view, TO_TSQUERY(''' || REPLACE(p_tags,'''','''''') || '''::text) query
            WHERE (query @@ textsearch OR (user_id = ANY(''' || following_ids::text || ''')) ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_GROUPS = 'SELECT count(*) as total
            FROM groups_taggings_view, TO_TSQUERY(''' || REPLACE(p_tags,'''','''''') || '''::text) query
            WHERE (query @@ textsearch)';
        ELSE

          SQL_CONVERSATIONS = 'SELECT count(*) as total
            FROM conversations_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_MEDIA = 'SELECT count(*) as total
            FROM media_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_QUESTIONS = 'SELECT count(*) as total
            FROM questions_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_LINKS = 'SELECT count(*) as total
            FROM links_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch ) AND NOT (user_id = ANY(''' || blocked_ids::text || '''))';

          SQL_GROUPS = 'SELECT count(*) as total
            FROM groups_taggings_view, TO_TSQUERY(''' || p_search || '''::text) query
            WHERE (''' || p_search || '''::text @@ tags OR query @@ textsearch )';


        END IF;
        SQL = 'SELECT SUM(total) AS total FROM
          (
            (' || SQL_CONVERSATIONS || ')  UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTIONS || ') UNION (' || SQL_LINKS || ') UNION (' || SQL_GROUPS || ')
          ) AS record';

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS  search_results_total(p_search VARCHAR);
DROP FUNCTION IF EXISTS search_results_total(p_search VARCHAR,p_blocked_ids VARCHAR,p_following_ids VARCHAR,p_tags VARCHAR);";
  end
end