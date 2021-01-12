# require 'aws-sdk'
# require 'Thread'

# Class which will poll SQS for job state notifications in a separate thread.
# This class is intended for batch-processing.  If you are using a ruby-on-rails
# server, then a better implementation would be to subscribe your server
# directly to the notification topic and process the SNS messages directly.
class SqsQueueNotificationWorker
  include ActiveModel::Model

  def initialize(region, queue_url, mediafile_id, job_id, options = {})
    options = { max_messages: 5, visibility_timeout: 15, wait_time_seconds: 5 }.merge(options)
    @region = region
    @queue_url = queue_url
    @mediafile_id = mediafile_id
    @job_id = job_id
    @max_messages = options[:max_messages]
    @visibility_timeout = options[:visibility_timeout]
    @wait_time_seconds = options[:wait_time_seconds]
    @handlers = []
  end

  def start()
    @shutdown = false
    @thread = Thread.new {poll_and_handle_messages}
  end

  def stop()
    @shutdown = true
    mediafile = MediaFile.find(@mediafile_id)

    bucket_name = ENV['AMAZON_S3_BUCKET_VIDEO_OUTPUT']

    # Get the bucket information
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]
    obj = bucket.objects[mediafile.unique_folder + '/' + mediafile.file_name + '.mp4']
    obj.acl = :public_read
    # Figure out ways in which we can improve speed of video encoding therefore commenting out this format
    # obj = bucket.objects[mediafile.unique_folder + '/' + mediafile.file_name + '.webm']
    # obj.acl = :public_read

    bucket_name = ENV['AMAZON_S3_BUCKET_VIDEO_THUMBNAIL']

    # Get the bucket information
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]
    obj = bucket.objects[mediafile.unique_folder + '/' + '00001' + mediafile.file_name + '.png']
    obj.acl = :public_read
    
    transcoder = AWS::ElasticTranscoder::Client.new(
      access_key_id: ENV['AMAZON_S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['AMAZON_S3_SECRET_ACCESS_KEY'],
      region: ENV['AMAZON_PIPELINE_REGION']
    )
    job = transcoder.read_job({id:@job_id})
    mediafile.duration = Time.at(job.job.output.duration).utc.strftime("%H:%M:%S")
    mediafile.job_id = @job_id
    mediafile.processed = true
    BusyPipeline.where(job_id: @job_id).destroy_all
    mediafile.save
  end

  def add_handler(handler)
    @handlers << handler
  end

  def remove_handler(handler)
    @handlers -= [handler]
  end

  def poll_and_handle_messages()
    sqs_client = AWS::SQS::Client.new(region: @region)
    while not @shutdown do
      sqs_messages = sqs_client.receive_message(
        queue_url: @queue_url,
        max_number_of_messages: @max_messages,
        wait_time_seconds: @wait_time_seconds).data[:messages]

      next if sqs_messages == nil

      sqs_messages.each do |sqs_message|
        notification = JSON.parse(JSON.parse(sqs_message[:body])['Message'])
        @handlers.each do |handler|
          handler.call(notification)
          sqs_client.delete_message(queue_url: @queue_url, receipt_handle: sqs_message[:receipt_handle])
        end
      end
    end
  end
end