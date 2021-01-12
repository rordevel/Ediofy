class Ediofy::AwsController < EdiofyController
  def s3_access_token
    @upload_type = params[:upload_type]
    render json: {
      policy:    s3_upload_policy,
      signature: s3_upload_signature,
      key:       ENV['AMAZON_S3_ACCESS_KEY_ID']
    }
  end

protected

  def s3_upload_policy
    @policy ||= create_s3_upload_policy
  end

  def create_s3_upload_policy
    bucket = (@upload_type == 'video') ? ENV['AMAZON_S3_BUCKET_VIDEO_INPUT'] : ENV['AMAZON_S3_BUCKET']
    # length = (@upload_type == 'video') ? 500 * 1024 * 1024 : 20 * 1024 * 1024
    if @upload_type == 'video'
      length = 500 * 1024 * 1024
    elsif @upload_type == 'audio'
      length = 50 * 1024 * 1024
    else
      length = 20 * 1024 * 1024
    end
    policy_document = {
      "expiration": 1.hour.from_now.utc.xmlschema,
      "conditions": [
        { "bucket":  bucket },
        [ "starts-with", "$key", "" ],
        { "acl": "public-read" },
        [ "starts-with", "$Content-Type", "" ],
        [ "content-length-range", 0, length ],
        { "success_action_status" => "201"}
      ]
    }.to_json
    Base64.encode64(policy_document).gsub("\n","")
  end

  def s3_upload_signature
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), ENV['AMAZON_S3_SECRET_ACCESS_KEY'], s3_upload_policy)).gsub("\n","")
  end
end