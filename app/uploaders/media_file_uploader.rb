class MediaFileUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include ::CarrierWave::Backgrounder::Delay

  storage :fog

  process :store_geometry

  ## Use cloudfront URLs
  configure do |config|
    if ENV["MODE"] == "staging"
      config.asset_host = 'https://d3sewyvdpevu6.cloudfront.net'
    elsif ENV["MODE"] == "production"
      config.asset_host = 'https://d2abwsjwb35y7g.cloudfront.net'
    end
  end

  def set_content_type
    file.content_type if file.respond_to? :content_type
  end

  def store_geometry
    file_info = model.file_info
    vers = version_name || 'base'
    Rails.logger.info("[MEDIA]-(#{model.id}) Processing size for version:#{vers}")
    geom = []

    if image?
      Rails.logger.info("[MEDIA]-(#{model.id}) version:#{vers} is image")
      geom = [].tap do |size|
        manipulate! do |img|
          size << img.columns
          size << img.rows
          img
        end
      end
    end
    if image? && !geom.empty?
      file_info.delete(vers.to_sym)
      geom_hash = { vers.to_sym => geom }
      model.file_info = geom_hash.merge file_info
    end
  end

  def store_dir
    "uploads/#{model.class.to_s. underscore}/#{mounted_as}/#{model.id}"
  end

  def mime_type
    if file.is_a?(CarrierWave::SanitizedFile) and File.exist? file.path
      fpoint = IO.popen(["file", "--brief", "--mime-type", file.path], in: :close, err: :close, close_others: true)
      mime_type = fpoint.read.chomp
      fpoint.close
    elsif file.respond_to? :content_type and file.content_type
      mime_type = file.content_type
    else
      mime_type = MIME::Types.of(filename).first.try(:to_s)
    end
    mime_type
  end

  def media_type
    if model.present? and model.respond_to?(:media_type) and model.persisted?
      model.media_type
    elsif file.present?
      (mime_type || "").split("/", 2).first
    end
  end

  def image? options={}
    media_type == "image"
  end

  def audio? options={}
    media_type == "audio"
  end

  def video? options={}
    media_type == "video"
  end
  
  def auto_orient_and_resize_to_fit width, height
    manipulate! do |image|
      image.auto_orient!
      image.resize_to_fit! width, height
    end
  end

  def auto_orient_and_resize_to_fill width, height
    manipulate! do |image|
      image.auto_orient!
      image.resize_to_fill! width, height
    end
  end

  # When moved to S3, this processing should probably get a little smarter
  # and maybe be spun into a background thread or summink
  version :thumb do
    # include RenameToImageIfVideo

    process auto_orient_and_resize_to_fill: Media::IMAGE_SIZES[:thumb], if: :image?
    # process screenshot_and_resize: Media::VIDEO_SIZES[:thumb], if: :video?
    process :store_geometry
    process :set_content_type

    # Audio doesn't process a thumbnail, but we need to show *something*
    def url
      if audio?
        "ediofy/media-file-audio-thumb-default.png"
      elsif video? && model.processing?
        "ediofy/media-file-video-thumb-default.png"
      elsif image? && model.processing?
        "ediofy/media-file-image-thumb-default.png"
      elsif model.processing?
        "ediofy/media-file-image-thumb-default.png"
      else
        super
      end
    end
  end

  version :small do#, if: :image? do

    process auto_orient_and_resize_to_fit: Media::IMAGE_SIZES[:small], if: :image?
    process :store_geometry
    process :set_content_type
  end

  version :medium do#, if: :image? do

    process auto_orient_and_resize_to_fit: Media::IMAGE_SIZES[:medium], if: :image?
    process :store_geometry
    process :set_content_type
  end

  version :large do

    process auto_orient_and_resize_to_fit: Media::IMAGE_SIZES[:large], if: :image?
    process :store_geometry
    process :set_content_type
  end
end
