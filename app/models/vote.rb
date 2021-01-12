class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user, foreign_key: :voter_id

  def self.ratings(title = nil)
    sql = <<-SQL
      SELECT
        votes.votable_id AS id,
        votes.votable_type AS type,
        COALESCE(media.title, question_translations.body) AS content_title,
        users.id AS user_id,
        CONCAT(users.first_name, ' ', users.last_name) AS user_name,
        SUM(votes.vote_weight) thumb_down,
        (
          SELECT created_at
          FROM votes
          WHERE votable_id = votes.votable_id
          ORDER BY created_at DESC
          LIMIT 1
        ) last_voted_thumbs_down
      FROM votes
      LEFT JOIN media ON (votes.votable_type = 'Media' AND media.id = votes.votable_id)
      LEFT JOIN questions ON (votes.votable_type = 'Question' AND questions.id = votes.votable_id)
      LEFT JOIN question_translations ON question_translations.question_id = questions.id
      JOIN users ON users.id IN (media.user_id, questions.user_id)
      WHERE votes.vote_flag = FALSE
      AND (? IS NULL OR media.title ILIKE CONCAT('%', ?, '%') OR question_translations.body ILIKE CONCAT('%', ?, '%'))
      GROUP BY votes.votable_id, votes.votable_type, content_title, users.id
      ORDER BY votes.votable_type
    SQL

    connection.execute(sanitize_sql([sql, title, title, title]))
  end
end
