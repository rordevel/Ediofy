class AddDeletedFalseToUserContributionsConversationsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS user_contributions_conversations_total(p_user_id INTEGER, p_search VARCHAR);
    CREATE OR REPLACE FUNCTION user_contributions_conversations_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_CONVERSATIONS TEXT;
        SQL TEXT;
      BEGIN
        SQL_CONVERSATIONS = 'SELECT COUNT(*) AS total
          FROM conversations
          WHERE deleted = FALSE AND user_id = ' || p_user_id;


        FOR ROW IN EXECUTE SQL_CONVERSATIONS LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS user_contributions_conversations_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
