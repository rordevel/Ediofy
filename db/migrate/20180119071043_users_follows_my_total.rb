class UsersFollowsMyTotal < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_follows_my_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
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
          FROM follows 
          WHERE follower_id = ' || p_user_id || ' AND follows.follower_type = ''User''';

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION users_follows_my_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
