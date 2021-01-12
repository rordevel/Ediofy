class CreateUniversityPointsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW universities_points AS 
      SELECT
        u.id AS university_id,
        COALESCE(SUM(p.value),0) AS points
      FROM
        universities u
      LEFT OUTER JOIN
        users m
      ON
        m.university_group_id = u.id
      LEFT OUTER JOIN
        points p
      ON
        m.id=p.user_id
      GROUP BY
      u.id)
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS universities_points;"
  end
end
