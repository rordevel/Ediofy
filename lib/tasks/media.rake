require "resque/tasks"

desc 'Find media without a MediaCollection and create/add them to one'
task "media:media_collections_build" => :environment do
  ActiveRecord::Base.record_timestamps = false
  Media.observers.disable :all
  MediaCollection.observers.disable :all
  Media.includes(:media_collection).where( media_collection: { id: nil}, type: nil ).each do |media|
    collection = MediaCollection.new(
      title: media.title,
      description: media.description,
      private: media.private
    )
    collection.member_id = media.member_id
    collection.created_at = media.created_at
    collection.updated_at = Time.now
    collection.save
    collection.media << media
    collection.save
  end
  Media.observers.enable :all
  MediaCollection.observers.enable :all
  ActiveRecord::Base.record_timestamps = true
end

desc 'Re-queue broken media that didn\'t queue'
task "media:requeue", [:media_id] => :environment do |t,args|
  args.with_defaults( media_id: 0 )

  unless args[:media_id].to_i == 0
    media = Media.find(args[:media_id])
    ::CarrierWave::Backgrounder.enqueue_for_backend(::CarrierWave::Workers::StoreAsset, media.class.name, media.id, media.file.mounted_as)
    puts "Media##{media.id} queued."
  end
end