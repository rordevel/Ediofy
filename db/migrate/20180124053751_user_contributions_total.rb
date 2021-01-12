class UserContributionsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION user_contributions_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
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
      BEGIN
        SQL_CONVERSATIONS = 'SELECT COUNT(*) AS total
          FROM conversations
          WHERE user_id = ' || p_user_id;

        SQL_MEDIA = 'SELECT COUNT(*) AS total
          FROM media
          WHERE user_id = ' || p_user_id || ' AND  private = FALSE';

        SQL_QUESTOINS = 'SELECT COUNT(*) AS total
          FROM questions
          WHERE user_id = ' || p_user_id || ' AND approved = TRUE AND status <> 2';

        SQL_LINKS = 'SELECT COUNT(*) AS total
          FROM links
          WHERE user_id = ' || p_user_id;

        SQL = 'SELECT SUM(record.total) AS total FROM
          (
            (' || SQL_CONVERSATIONS || ')  UNION (' || SQL_MEDIA || ') UNION (' || SQL_QUESTOINS || ') UNION (' || SQL_LINKS || ')
          ) AS record';

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION user_contributions_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
