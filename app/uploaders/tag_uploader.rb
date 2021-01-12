class TagUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    ['jpg', 'jpeg', 'gif', 'png', '']
  end

  version :medium do
    process resize_to_fill: [186, 105]

    def default_url
      super size: 186
    end
  end
  
end
