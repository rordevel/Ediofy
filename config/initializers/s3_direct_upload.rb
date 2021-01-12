S3DirectUpload.config do |c|
  c.access_key_id = ENV["AMAZON_S3_ACCESS_KEY_ID"]
  c.secret_access_key = ENV["AMAZON_S3_SECRET_ACCESS_KEY"]
  c.bucket = ENV["AMAZON_S3_BUCKET"]
  c.region = ENV["AMAZON_S3_REGION"]
  c.url = "https://#{ENV["AMAZON_S3_BUCKET"]}.s3.amazonaws.com/"
end