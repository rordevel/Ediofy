class ImageAttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include ::CarrierWave::Backgrounder::Delay
  storage :fog
  
  ## Use cloudfront URLs
  configure do |config|
    ## production site cloud front url: https://d2abwsjwb35y7g.cloudfront.net
    if Rails.env.production?
      config.asset_host =  ENV["CLOUDFRONT_URL"]
    end
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: Media::IMAGE_SIZES[:thumb]
  end

  version :small do
    process resize_to_fit: Media::IMAGE_SIZES[:small]
  end

  version :medium do
    process resize_to_fit: Media::IMAGE_SIZES[:medium]
  end
  
  version :large do
    process resize_to_fit: Media::IMAGE_SIZES[:large]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
