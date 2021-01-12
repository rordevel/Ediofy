class CopyConversationDescriptionToTitle < ActiveRecord::Migration[5.0]
  def up
    conversation = Conversation.all
    conversation.each do |c|
      if c.title.nil?
        puts "Conversation id = #{c.id}"
        unless c.description.nil?
          c.title = c.description.length >= 50 ? c.description.truncate(53) : c.description
          c.save(:validate => false)
        end
      end
    end
  end
end
