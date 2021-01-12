class UserContributionsQuestionsTotal < ActiveRecord::Migration[5.0]
  def up
    execute "DROP FUNCTION IF EXISTS user_contributions_questions_total(p_user_id INTEGER, p_search VARCHAR);
    CREATE OR REPLACE FUNCTION user_contributions_questions_total(p_user_id INTEGER, p_search VARCHAR DEFAULT NULL)
      RETURNS TABLE(
        total BIGINT
      )
      AS $$
      DECLARE
        ROW RECORD;
        SQL_QUESTIONS TEXT;
        SQL TEXT;
      BEGIN
        SQL_QUESTIONS = 'SELECT COUNT(*) AS total
          FROM questions
          WHERE user_id = ' || p_user_id;


        FOR ROW IN EXECUTE SQL_QUESTIONS LOOP
          total := row.total;
          RETURN NEXT;
        END LOOP;
      END; $$
    LANGUAGE 'plpgsql';"
  end

  def down
    execute "DROP FUNCTION IF EXISTS user_contributions_questions_total(p_user_id INTEGER, p_search VARCHAR)";
  end
end
