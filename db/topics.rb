module Import
  class Topics
    def self.imed_topic_migration
      Topic.imed.each do |t|
        if (Topic.gmep.where( :title => t.title ).count == 0) && (t.title != "All")
          Topic.gmep.create( :title => t.title)
        end
      end

      goodcount = 0;
      badcount = 0;
      Subject.all.each do |s|
        parent = Topic.find(s.topic_id)
        new_parent = Topic.gmep.where(:title => parent.title).first
        if new_parent.present?
          goodcount = goodcount + 1
          Topic.gmep.create( :title => s.title, :parent_id => new_parent.id ) if Topic.gmep.where( :title => s.title ).count == 0
        else
          badcount = badcount + 1
        end
      end

      puts "Success: #{goodcount}"
      puts "Fail: #{badcount}"
    end

    def self.gmep_generate_topic_csv
      require 'csv'
      csv_string = CSV.generate do |csv|
        first_topic=Topic.gmep.first
        csv << first_topic.attributes.collect{ |a| a[0].to_s }
        Topic.gmep.each do |t|
          csv << t.attributes.collect{ |a| a[1].to_s }
        end
      end

      File.open('ediofy_topics.csv', 'w') do |f2|
        f2.puts csv_string
      end
    end


    def self.gmep_topic_import_csv
      require 'csv'
      lastubertopic = ''
      ubertopicid = 0
      topiccount = 0
      CSV.foreach("db/ediofy_topics.csv") do |row|
        unless row[0] == "SITE"
          ubertopic = row[5]
          topic = row[6]
          if ubertopic != lastubertopic
            lastubertopic = ubertopic
            t = Topic.gmep.create(:title => ubertopic)
            ubertopicid = t.id
            puts "Created parent topic #{ubertopic}"
          else
            t = Topic.gmep.create(title: topic, parent_id: ubertopicid)
            puts "Created topic #{topic} parented by #{ubertopic}"
          end
          topiccount += 1
        end
      end
      puts "Done. #{topiccount} topics created"
    end
  end
end