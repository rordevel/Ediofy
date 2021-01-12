class AddGhostConditionToUsersFollowsAllTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_follows_all_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        tags TEXT;
      BEGIN
        SQL = 'SELECT COUNT(*) AS total
          FROM users
          WHERE id != ' || p_user_id || ' AND ediofy_terms_accepted = true AND profile_completed = true AND ghost_mode = false';

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION users_follows_all_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
