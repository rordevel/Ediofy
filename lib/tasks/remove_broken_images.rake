require "resque/tasks"
require 'aws-sdk'

desc 'Removes broken links'
task "remove:broken_links" => :environment do
  media_all = Media.all
  media_all.each do |media|
    media.media_files.each do |media_file|
      begin
        uri = URI(media_file.large_url)
        request = Net::HTTP.new uri.host
        response= request.request_head uri.path
        puts "Media id = #{media.id}"
        puts "file code = #{response.code.to_i}"
        if response.code.to_i != 200
          media_file.destroy
        end
      rescue Exception => error
        if media_file.media_type.nil?
          media_file.destroy
        end
        puts error
        puts "Media id = #{media.id}"
        puts "Media url = #{media_file.large_url}"
      end

    end
  end

end