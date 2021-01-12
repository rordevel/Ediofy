class CreateUserContributionsVideoTotals < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS user_contributions_video_total(p_user_id INTEGER, p_search VARCHAR);
    CREATE OR REPLACE FUNCTION user_contributions_video_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_MEDIA TEXT;
        SQL TEXT;
      BEGIN
        SQL_MEDIA = 'SELECT COUNT(*) AS total
          FROM media JOIN media_files ON media_files.media_id = media.id AND media_files.media_type = ''video''
          WHERE user_id = ' || p_user_id;


        FOR ROW IN EXECUTE SQL_MEDIA LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS user_contributions_video_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
