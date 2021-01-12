class UsersFollowsMy < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE OR REPLACE FUNCTION users_follows_my(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR DEFAULT NULL, p_sort VARCHAR = 'latest')
      RETURNS TABLE(
        id INTEGER
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
        tags TEXT;
      BEGIN
        SQL = 'SELECT followable_id 
          FROM follows 
          WHERE follower_id = ' || p_user_id || ' AND follows.follower_type = ''User''
          LIMIT ' || p_limit || ' OFFSET ' || p_offset || '';

        FOR ROW IN EXECUTE SQL LOOP
          id := row.followable_id::INTEGER;

          RETURN NEXT;
        END LOOP;
      END; $$ 
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION users_follows_my(p_limit INTEGER, p_offset INTEGER, p_user_id INTEGER, p_search VARCHAR, p_sort VARCHAR)";
  end
end
