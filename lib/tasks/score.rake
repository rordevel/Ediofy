require "resque/tasks"

desc 'Update all the scores across the site'
task "score:update" => :environment do
  puts "Updating Media scores..."
  Media.record_timestamps = false
  Media.find_each(:batch_size => 100, :conditions => { type: nil }) do |media|
    puts "Updating Media##{media.id}"
    media.update_score!
  end
  Media.record_timestamps = true

  Question.record_timestamps = false
  puts "Updating Question scores..."
  Question.find_each(:batch_size => 100) do |question|
    puts "Updating Question##{question.id}"
    question.update_score!
  end
  Question.record_timestamps = true

end