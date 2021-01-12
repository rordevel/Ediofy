class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  if Rails.env.production? || Rails.env.demo?
    storage :fog
  else
    storage :file
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    ['jpg', 'jpeg', 'gif', 'png', '']
  end

  def default_url options={}
    ActionController::Base.helpers.asset_path("ediofy/default-profile-img.png")
    # "ediofy/default-profile-img.png"
  end

  version :xxx_small do
    process resize_to_fill: [28,28]

    def default_url
      super size: 28
    end
  end

  version :xx_small do
    process resize_to_fill: [30,30]

    def default_url
      super size: 30
    end
  end

  version :x_small do
    process resize_to_fill: [55,55]

    def default_url
      super size: 55
    end
  end

  version :small do
    process resize_to_fill: [100,100]

    def default_url
      super size: 72
    end
  end

  version :x_medium do
    process resize_to_fill: [154, 154]

    def default_url
      super size: 154
    end
  end

  version :medium do
    process resize_to_fill: [263,156]

    def default_url
      super size: 263
    end
  end

  # for image size validation
  # fetching dimensions in uploader, validating it in model
  attr_reader :width, :height
  before :cache, :capture_size
  def capture_size(file)
    if version_name.blank? # Only do this once, to the original version
      if file.path.nil? # file sometimes is in memory
        img = ::MiniMagick::Image::read(file.file)
        @width = img[:width]
        @height = img[:height]
      else
        @width, @height = `identify -format "%wx %h" #{file.path}`.split(/x/).map{|dim| dim.to_i }
      end
    end
  end
  
end
