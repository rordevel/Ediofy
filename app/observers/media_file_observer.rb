class MediaFileObserver < ActiveRecord::Observer
  def after_create media_file
    if media_file.image?
      media_file.user.activity! "image_files.new", media_file: media_file, default_points: Media::SUBMIT_POINTS, cpd_time: ActivityKeyPointValue.find_by(activity_key: 'image_files.new')&.cpd_time
    elsif media_file.audio?
      t = Time.parse(media_file.duration)
      mins = t.min
      mins += 1 if t.sec > 0
      mins = mins > 6 ? 6 : mins
      spd_time = (ActivityKeyPointValue.find_by(activity_key: 'media_files.new')&.cpd_time || 0) * mins
      media_file.user.activity! "media_files.new", media_file: media_file, default_points: Media::SUBMIT_POINTS, cpd_time: spd_time
    elsif media_file.pdf?
      io = open(media_file.s3_file_url)
      reader = PDF::Reader.new(io)
      page_count = reader.page_count > 5 ? 5 : reader.page_count
      spd_time = (ActivityKeyPointValue.find_by(activity_key: 'pdf_files.new')&.cpd_time || 0) * page_count
      media_file.user.activity! "pdf_files.new", media_file: media_file, default_points: Media::SUBMIT_POINTS, cpd_time: spd_time
    end
  end
end
