class MediaFile < ActiveRecord::Base
  #not being used in BETA
  # include Scorable
  include Rails.application.routes.url_helpers
  belongs_to :media
  has_one :user, through: :media
  before_validation :set_media_type
  has_many :attachments
  has_many :questions, through: :attachments, source: :attachable, source_type: "Question"
  has_many :conversations, through: :attachments, source: :attachable, source_type: "Conversation"
  mount_uploader :file, MediaFileUploader

  acts_as_votable cacheable_strategy: :update_columns
  acts_as_commentable
  acts_as_taggable
  serialize :file_info
  delegate :image?, :audio?, :video?, to: :file, allow_nil: true

  store_in_background :file unless Rails.env.test?
  enum status: [:reported, :displayed, :removed]
  delegate :title, :description, to: :media, allow_nil: true

  VALID_EXTENTIONS = ['pdf','jpg', 'jpeg', 'png', 'gif', 'mp4', 'mpg', 'm4v', 'mov', 'mkv', 'avi', 'ogg', 'ogv', 'wmv', 'webm', '3gp', '3g2', 'wav', 'mp3', 'm4a', 'aac']
  VALID_IMAGE_EXTENTIONS = ['jpg', 'jpeg', 'png', 'gif' ]
  VALID_AUDIO_EXTENTIONS = ['wav', 'mp3', 'aac', 'm4a', 'ogg']
  VALID_VIDEO_EXTENTIONS = ['mp4', 'mpg', 'm4v', 'mov', 'mkv', 'avi', 'ogg', 'ogv', 'wmv', 'webm', '3gp', '3g2']

  before_save :set_audio_duration
  after_create :upload_to_s3_or_transcode
  after_update :after_update_processed_changed, if: lambda{|m| m.processed_changed? && m.processed }
  def upload_to_s3_or_transcode
    if self.image?
      self.remote_file_url = self.s3_file_url
      self.save
    elsif self.video?
      transcode = Transcoder.new(self)
      transcode.create
    end
  end

  def small_url
    (file.blank?) ? s3_file_url : file_url(:small)
  end

  def medium_url
    (file.blank?) ? s3_file_url : file_url(:medium)
  end

  def large_url
    (file.blank?) ? s3_file_url : file_url(:large)
  end

  def video_thumb_url
    "https://s3-"+ ENV['AMAZON_S3_REGION'] +".amazonaws.com/" + ENV['AMAZON_S3_BUCKET_VIDEO_THUMBNAIL'] + "/" + self.unique_folder + "/00001" + self.file_name + ".png"
  end

  def video_url_mp4
    self.processed ? "https://s3-"+ ENV['AMAZON_S3_REGION'] +".amazonaws.com/" + ENV['AMAZON_S3_BUCKET_VIDEO_OUTPUT'] + "/" + self.unique_folder + "/" + self.file_name + ".mp4" : 'ediofy/ediofy-placeholder.png'
  end

  # Figure out ways in which we can improve speed of video encoding therefore commenting out this format
  # def video_url_webm
  #   self.processed ? "https://s3-"+ ENV['AMAZON_S3_REGION'] +".amazonaws.com/" + ENV['AMAZON_S3_BUCKET_VIDEO_OUTPUT'] + "/" + self.unique_folder + "/" + self.file_name + ".webm" : 'ediofy/ediofy-placeholder.png'
  # end

  # def video_url_ogv
  #   self.processed ? "https://s3-"+ ENV['AMAZON_S3_REGION'] +".amazonaws.com/" + ENV['AMAZON_S3_BUCKET_VIDEO_OUTPUT'] + "/" + self.unique_folder + "/" + self.file_name + ".ogv" : 'ediofy/ediofy-placeholder.png'
  # end

  def after_update_processed_changed
    ActionCable.server.broadcast("media_file_#{self.id}_channel", {
      id: self.id,
      processed: self.processed,
      video_url_mp4: self.video_url_mp4,
      video_thumb_url: self.video_thumb_url
    })

    self.media.user.notifications.create(
      title: I18n.t("notification.media.processed.title"),
      notification_type: "MediaProcessed",
      body:  I18n.t("notification.media.processed.body_html",
        content: self.media.title,
        content_url: ediofy_media_path(self.media)),
      image_url: self.media.user.avatar.x_small.url,
      links: []
    )
    NotificationMailer.media_processed(self.media.user, self.media.id).deliver_later

    if duration.present?
      t = Time.parse(duration)
      mins = t.min
      mins += 1 if t.sec > 0
      mins = mins > 6 ? 6 : mins
      spd_time = (ActivityKeyPointValue.find_by(activity_key: 'media_files.new')&.cpd_time || 0) * mins
      user.activity! "media_files.new", media_file: self, default_points: Media::SUBMIT_POINTS, cpd_time: spd_time
    end
  end

  def self.not_over_reported
    where("media.reports_count < ?", 5)
  end

  def file_name
    self.s3_file_name.rpartition(".").first
  end

  def unique_folder
    file_path = URI.unescape(self.file_path)
    file_path.split("/")[-2]
  end

  def oembedable
    if processing? || private
      false
    else
      super
    end
  end

  def oembed_type
    if media_type == "image"
      :photo
    elsif media_type == "video"
      :video
    else
      :rich
    end
  end

  def oembed_thumbnail_url
    file.thumb.url
  end

  def oembed_thumbnail_width
    128
  end

  def oembed_thumbnail_height
    128
  end

  def oembed_max_dimensions(max_width=nil, max_height=nil)
    if video?
      ar = file_info[:base][0].to_f/file_info[:base][1].to_f
      Rails.logger.info("[OEMBED] Aspect: #{ar}")
      width=VIDEO_SIZES[:large][0]
      height=(width/ar).to_i
      [width, height+52]
    elsif image?
      # always fall back to the original file
      chosen = :base

      # smallest to largest, picks the best fit, replacing chosen until it no longer fits
      IMAGE_SIZES.each do |size,dimension|
        if file_info[size].present?
          chosen = size if ((max_width.to_i > dimension[0].to_i))
        end
      end

      if chosen == :base
        self.oembed_url = file.url
      else
        self.oembed_url = file.send(chosen).url
      end
      [file_info[chosen][0],file_info[chosen][1]]
    end
  end
  def image?
    media_type.to_s.downcase == "image"
  end
  def audio?
    media_type.to_s.downcase == "audio"
  end
  def video?
    media_type.to_s.downcase == "video"
  end
  def pdf?
    (self.file.present? && self.file.file.extension.downcase == "pdf") || media_type.to_s.downcase == "pdf"
  end
  def oembed_max_width(maxwidth)
    maxwidth = maxwidth.to_i
    orig_width = file_info[:base][0]
    large_width = file_info[:large][0]

    if maxwidth.present?
      if maxwidth > large_width && maxwidth < orig_width
        orig_width
      else
        large_width
      end
    else
      large_width
    end
  end

  def oembed_max_height(maxheight)
    maxheight = maxheight.to_i
    orig_height = file_info[:base][1]
    large_height = file_info[:large][1]

    if maxheight.present?
      if maxheight > large_height && maxheight < orig_height
        orig_height
      else
        large_height
      end
    else
      large_height
    end
  end

  def file_info
    super || {}
  end
  def set_duration(seconds)
    minutes = format('%02d', seconds.to_i/60)
    seconds = format('%02d', seconds.to_i%60)
    self.update_column(:duration, minutes + ":" + seconds)
  end

  def self.visible_to user
    if user
      memid = user.id
      joins(:media).where("media.private = ? OR media.user_id = ?", false, memid)
    else
      joins(:media).where(private: false)
    end
  end

  def processing?
    file_tmp.present? || file_processing?
  end

  def to_s
    title
  end
  protected
  def set_media_type
    self.media_type = file.media_type if self.media_type.blank?
  end
  def validate_extension
    unless VALID_EXTENSIONS.include?(file.file.extension.downcase)
      self.errors.add(:media_type, "wrong media type")
    end
  end
  def set_file_size
    if file.present? && file_changed?
      file_info ||= {}
      file_info = file_info.merge({size: file.file.size})
    end
  end
  def set_audio_duration
    if audio? && !duration.present? && s3_file_url.present?
      media_info = MediaInfo.from(s3_file_url)
      duration_sec = (media_info.audio.duration.to_f / 1000).round
      self.duration = Time.at(duration_sec).utc.strftime("%H:%M:%S")
    end
  end
end
