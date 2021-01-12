class BadgeImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    # This should be passed to image_tag so it is found by the asset pipeline
    ["default", version_name, "badge.png"].compact.join('_')
  end

  version :stream do
    process resize_to_fit: [32, 32]
  end

  version :thumb do
    process resize_to_fit: [128, 128]
  end

  version :notification do
    process resize_to_fit: [256, 256]
  end

  version :large do
    process resize_to_fit: [512, 512]
  end
end
