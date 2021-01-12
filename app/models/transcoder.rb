class Transcoder < MediaFile
  def initialize(mediafile)
    @mediafile = mediafile
  end
  def select_pipeline_and_queue
    pipeline_counter = 0
    all_pipelines = ENV['AMAZON_PIPELINE_ID'].split(',')
    all_queues = ENV['AMAZON_QUEUE'].split(',')
    busy_pipelines = BusyPipeline.all.map(&:pipeline_id)
    available_pipelines = all_pipelines - busy_pipelines
    available_pipelines = all_pipelines if available_pipelines.count == 0
    selected_pipeline = available_pipelines.sample
    selected_queue = all_queues[all_pipelines.index(selected_pipeline)]
    return selected_pipeline,selected_queue
  end
  def create
    pipeline_id,queue = select_pipeline_and_queue
    transcoder = AWS::ElasticTranscoder::Client.new(
      access_key_id: ENV['AMAZON_S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['AMAZON_S3_SECRET_ACCESS_KEY'],
      region: ENV['AMAZON_PIPELINE_REGION']
    )
    options = {
      pipeline_id: pipeline_id,
      input: { 
        key: "uploads/#{@mediafile.unique_folder}/#{@mediafile.s3_file_name}",# + @mediafile.extension, #@mediafile.file.split("/")[3..-1].join("/"), # slice off the amazon.com bit 
        frame_rate: "auto", 
        resolution: 'auto', 
        aspect_ratio: 'auto', 
        interlaced: 'auto', 
        container: 'auto' 
        },
      outputs: [
        {
          key: "#{@mediafile.unique_folder}/#{@mediafile.file_name}.mp4", 
          preset_id: '1351620000001-000040', 
          rotate: "auto", 
          thumbnail_pattern: "#{@mediafile.unique_folder}/{count}#{@mediafile.file_name}"
        }

        # Figure out ways in which we can improve speed of video encoding therefore commenting out this format
        # ,
        # {
        #   key: "#{@mediafile.unique_folder}/#{@mediafile.file_name}.webm", 
        #   preset_id: '1351620000001-100240', 
        #   rotate: "auto", 
        #   thumbnail_pattern: "#{@mediafile.unique_folder}/{count}#{@mediafile.file_name}"
        # }
      ]
    }
    job_id = transcoder.create_job(options)[:job][:id]
    # VideofileTranscodeJob.new.async.later(1, @mediafile.id, job_id)
    BusyPipeline.create(pipeline_id: pipeline_id, job_id: job_id)
    sqs_queue_url = "https://sqs.ap-southeast-2.amazonaws.com/489055221044/#{queue}"

    require_relative 'SqsQueueNotificationWorker'

    notification_worker = SqsQueueNotificationWorker.new(ENV['AMAZON_PIPELINE_REGION'], sqs_queue_url, @mediafile.id, job_id)
    completion_handler = lambda { |notification| notification_worker.stop if (notification['jobId'] == job_id && ['COMPLETED', 'ERROR'].include?(notification['state'])) }
    notification_worker.add_handler(completion_handler)
    notification_worker.start()
  end
end