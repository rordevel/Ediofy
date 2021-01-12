module PointsHelper
  def points_per_day_graph_for member, options={}
    points_per_day = Hash[member.points.per_day.past_7_days.map { |p| [Time.parse(p.period).beginning_of_day.to_i, p.value] }]
    days = (0...7).map { |hence| 7.days.ago.beginning_of_day + hence.days }.map(&:to_i)
    data = days.map { |day| [day * 1000, points_per_day[day] || 0] }

    options.merge!({xaxis: {mode: :time, tickSize: [1, "day"]}})

    content_tag :div, "", class: "plot points-per-day", data: {"plot" => [data].to_json, "plot-options" => options.to_json}, style: "width: 100%; height: 300px"
  end

  def points_per_week_graph_for member, options={}
    points_per_week = Hash[member.points.per_week.past_4_weeks.map { |p| [Time.parse(p.period).beginning_of_week.to_i, p.value] }]
    weeks = (0...4).map { |hence| 4.weeks.ago.beginning_of_week + hence.weeks }.map(&:to_i)
    data = weeks.map { |week| [week * 1000, points_per_week[week] || 0] }

    options.merge!({xaxis: {mode: :time, tickSize: [7, "day"]}})

    content_tag :div, "", class: "plot points-per-week", data: {"plot" => [data].to_json, "plot-options" => options.to_json}, style: "width: 100%; height: 300px"
  end

  def points_per_month_graph_for member, options={}
    points_per_month = Hash[member.points.per_month.past_year.map { |p| [Time.parse(p.period).beginning_of_month.to_i, p.value] }]
    months = (0...12).map { |hence| 1.year.ago.beginning_of_month + hence.months }.map(&:to_i)
    data = months.map { |month| [month * 1000, points_per_month[month] || 0] }

    options.merge!({xaxis: {mode: :time, tickSize: [1, "month"]}})

    content_tag :div, "", class: "plot points-per-month", data: {"plot" => [data].to_json, "plot-options" => options.to_json}, style: "width: 100%; height: 300px"
  end
end