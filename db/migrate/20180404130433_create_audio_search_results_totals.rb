class CreateAudioSearchResultsTotals < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS audio_search_results_total(p_search VARCHAR);
    CREATE OR REPLACE FUNCTION audio_search_results_total(p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL TEXT;
      BEGIN
        IF p_search IS NULL THEN
          SQL = 'SELECT COUNT(*) AS total
            FROM media JOIN media_files ON media_files.media_id = media.id AND media_files.media_type=''audio''';
        ELSE
          SQL = 'SELECT COUNT(*) AS total
            FROM (
              SELECT media.id, ''media'' AS type, TS_RANK_CD(textsearch, query) AS rank
              FROM media_taggings_view, TO_TSQUERY(''' || p_search || ''') query
              JOIN media_files ON media_files.media_id = media_taggings_view.id AND media_files.media_type=''audio''
              WHERE query @@ textsearch
            ) AS record';
        END IF;

        FOR ROW IN EXECUTE SQL LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS audio_search_results_total(p_search VARCHAR)";
  end

end
