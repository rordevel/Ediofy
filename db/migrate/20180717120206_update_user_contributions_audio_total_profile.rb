class UpdateUserContributionsAudioTotalProfile < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS user_contributions_audio_total(p_user_id INTEGER, p_search VARCHAR);
    CREATE OR REPLACE FUNCTION user_contributions_audio_total(p_user_id INTEGER, p_profile BOOLEAN, p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_MEDIA TEXT;
        SQL TEXT;
      BEGIN
        IF p_profile = true THEN
          SQL_MEDIA = 'SELECT COUNT(*) AS total
            FROM media JOIN media_files ON media_files.media_id = media.id AND media_files.media_type = ''audio''
            WHERE user_id = ' || p_user_id || ' AND  media.private = FALSE';
        ELSE
          SQL_MEDIA = 'SELECT COUNT(*) AS total
            FROM media JOIN media_files ON media_files.media_id = media.id AND media_files.media_type = ''audio''
            WHERE user_id = ' || p_user_id;
        END IF;


        FOR ROW IN EXECUTE SQL_MEDIA LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS user_contributions_audio_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
