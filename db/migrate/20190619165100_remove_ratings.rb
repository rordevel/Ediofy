class RemoveRatings < ActiveRecord::Migration[5.1]
  def up
    execute <<-SQL
      DROP FUNCTION ratings(VARCHAR);
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION ratings(p_content_title VARCHAR DEFAULT NULL)
        RETURNS TABLE(
          id INT,
          type VARCHAR,
          content_title VARCHAR,
          user_id INT,
          user_name VARCHAR,
          thumb_down INT,
          last_voted_thumbs_down VARCHAR
        )
        AS $$
        DECLARE
          ROW RECORD;
          sql TEXT;
        BEGIN
          sql = '
            SELECT   
              v.votable_id AS id, 
              v.votable_type AS type,
              qt.body AS content_title, 
              u.id AS user_id, 
              CONCAT(u.first_name, '' '', u.last_name) AS user_name, 
              SUM(v.vote_weight) thumb_down,
              (SELECT created_at FROM votes WHERE votable_id = v.votable_id ORDER BY created_at DESC LIMIT 1) last_voted_thumbs_down
            FROM votes v
            JOIN question_translations qt ON qt.question_id = v.votable_id
            JOIN questions q ON q.id = qt.question_id
            JOIN users u ON u.id = q.user_id
            WHERE v.vote_flag = FALSE AND v.votable_type = ''Question''';

            IF p_content_title IS NOT NULL THEN
              sql = sql || ' AND qt.body ILIKE ''%' || p_content_title || '%''';
            END IF;
            
            sql = sql || ' GROUP BY v.votable_id, v.votable_type, qt.body, u.first_name, u.last_name, u.id';

            sql = sql || ' UNION ';

            sql = sql || ' 
            SELECT   
              v.votable_id AS id, 
              v.votable_type AS type,
              m.title AS content_title, 
              u.id AS user_id, 
              CONCAT(u.first_name, '' '', u.last_name) AS user_name, 
              SUM(v.vote_weight) thumb_down,
              (SELECT created_at FROM votes WHERE votable_id = v.votable_id ORDER BY created_at DESC LIMIT 1) last_voted_thumbs_down
            FROM votes v
            JOIN media m ON m.id = v.votable_id
            JOIN users u ON u.id = m.user_id 
            WHERE v.vote_flag = FALSE AND v.votable_type = ''Media''';

            IF p_content_title IS NOT NULL THEN
              sql = sql || ' AND m.title ILIKE ''%' || p_content_title || '%''';
            END IF;
            
            sql = sql || ' GROUP BY v.votable_id, v.votable_type, m.title, u.first_name, u.last_name, u.id';
            
            FOR ROW IN EXECUTE SQL LOOP
              id := row.id;
              type := row.type;
              content_title := row.content_title;
              user_id := row.user_id;
              user_name := row.user_name;
              thumb_down := row.thumb_down;
              last_voted_thumbs_down := row.last_voted_thumbs_down;
              RETURN NEXT;
            END LOOP;
        END; $$
      LANGUAGE 'plpgsql';
    SQL
  end
end
