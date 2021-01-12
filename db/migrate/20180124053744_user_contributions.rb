class UserContributions < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION user_contributions(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
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
      BEGIN
        SQL_CONVERSATIONS = 'SELECT id, ''conversations'' AS type, 0 AS rank
          FROM conversations
          WHERE user_id = ' || p_user_id;

        SQL_MEDIA = 'SELECT id, ''media'' AS type, 0 AS rank
          FROM media
          WHERE user_id = ' || p_user_id || ' AND  private = FALSE';

        SQL_QUESTOINS = 'SELECT id, ''questions'' AS type, 0 AS rank
          FROM questions
          WHERE user_id = ' || p_user_id || ' AND approved = TRUE AND status <> 2';

        SQL_LINKS = 'SELECT id, ''links'' AS type, 0 AS rank
          FROM links
          WHERE user_id = ' || p_user_id;

        SQL = '(' || SQL_CONVERSATIONS || ') UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')';
        SQL = SQL || ' ORDER BY rank DESC';
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
    execute "DROP FUNCTION user_contributions(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
