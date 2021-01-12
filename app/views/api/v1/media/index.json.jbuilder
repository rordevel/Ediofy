json.status SUCCESS_STATUS
json.media do
  json.array! @media do |media|
    json.(
      media,
      :id, :user_id, :title, :media_type, :file, :reports_count, :question_media_count, :cached_votes_up, :cached_votes_down, :private, :score, :created_at, :updated_at, :status
    )
    json.description truncate_html media.description
  end
end