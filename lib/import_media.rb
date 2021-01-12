module Import
  class Media

    @file = nil
    @headers = []
    @data = []

    def initialize(file_path=nil)
      # The four lines below turn our CSV into an array of hashes
      @file       = CSV.read(file_path)
      @headers    = @file.shift.map{ |i| i.to_s }
      string_data = @file.map { |row| row.map { |cell| cell.to_s } }
      @data       = string_data.map { |row| Hash[*@headers.zip(row).flatten] }
    end


    def import
      current_collection = nil
      puts "Importing media.."
      @data.each_with_index do |media_info, key|

        puts "Importing row #{key} - #{media_info['title']}"
        tags = []

        (0..15).each do |i|
          tag = media_info["tag#{i}"]
          media_info.delete("tag#{i}")
          tags << tag
        end

        if current_collection.try(:title) != media_info["collection"]
          mc_title = "RCSI Illustrations - #{media_info['collection']}"
          current_collection = ::MediaCollection.find_or_create_by_title(mc_title)
          unless current_collection.persisted?
            current_collection.member_id = media_info["member_id"]
            current_collection.description = media_info["collection"]
            current_collection.save
          end
          puts "Media Collection is #{current_collection.id}-#{current_collection.title}"
        end

        media_info.delete("collection")
        media_info.delete('author')

        media_info["tag_list"] = tags.join(",")

        remote_file = media_info["remote_file_url"]
        member_id = media_info["member_id"]

        media = ::Media.create(media_info)
        media.remote_file_url = remote_file
        media.member_id = member_id
        media.save

        if media.valid?
          puts "Media is valid, putting in collection"
          current_collection.media << media
        end
        puts "-----------------"
      end
    end

  end
end