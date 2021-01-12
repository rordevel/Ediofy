class CreateUserPointsView < ActiveRecord::Migration[5.0]
  def up
    self.connection.execute %Q(CREATE OR REPLACE VIEW user_points AS
      SELECT
        m.id AS user_id,
        COALESCE(SUM(p.value),0) AS points
      FROM
        users m
      LEFT OUTER JOIN
        points p
      ON
        m.id=p.user_id
      GROUP BY
      m.id)
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS user_points;"
  end
end
