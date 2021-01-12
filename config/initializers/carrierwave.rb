CarrierWave.configure do |config|
  # We run before the railtie so this isn't set, here's the default:
  # ENV['HOME'] = '/home/ubuntu'
  # config.root = Rails.root.join(Rails.public_path).to_s
  config.storage = :fog
  config.fog_credentials = {
    :provider              => 'AWS',
    :aws_access_key_id     => ENV["AMAZON_S3_ACCESS_KEY_ID"],
    :aws_secret_access_key => ENV["AMAZON_S3_SECRET_ACCESS_KEY"],
    :region                => ENV["AMAZON_S3_REGION"]
  }
  config.fog_directory  = ENV["AMAZON_S3_BUCKET"]
  config.fog_public     = true
  config.fog_attributes = { 'Cache-Control' => "max-age=315576000" }
end