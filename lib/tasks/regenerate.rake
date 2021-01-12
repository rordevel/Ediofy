require "resque/tasks"

desc 'Regenerate all the media from S3 (this will use bandwidth!)'
task "media:queue_s3regenerate" => :environment do
  Media.where(type: nil).order('created_at DESC').each do |media|
    puts "Fetching file for ##{media.id}.."
    media.file.cache_stored_file!
    puts "Setting tmp."
    media.file_tmp = media.file.cache_name
    puts "Preparing to save.."
    media.class.record_timestamps = false
    media.save!
    puts "Saved."
    media.class.record_timestamps = true

    # ::CarrierWave::Backgrounder.enqueue_for_backend(::CarrierWave::Workers::StoreAsset, media.class.name, media.id, media.file.mounted_as)
    puts "Queue"
  end
end

desc 'Regenerate a specific media item'
task "media:regenerate", [:media_id] => :environment do |t,args|
  args.with_defaults( media_id: 0 )
  unless args[:media_id].to_i == 0
    media = Media.find(args[:media_id])
    puts "Fetching file for ##{media.id}.."
    media.file.cache_stored_file!
    puts "Setting tmp."
    media.file_tmp = media.file.cache_name
    puts "Preparing to save.."
    media.class.record_timestamps = false
    media.save!
    puts "Saved."
    media.class.record_timestamps = true
    # ::CarrierWave::Backgrounder.enqueue_for_backend(::CarrierWave::Workers::StoreAsset, media.class.name, media.id, media.file.mounted_as)
    puts "Queue"
  else
    puts
    puts
    $stderr.puts "Error, please provide a media id eg. rake media:regenerate[1]"
  end
end