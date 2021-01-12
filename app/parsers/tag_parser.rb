class TagParser < ActsAsTaggableOn::GenericParser
  def parse
    ActsAsTaggableOn::TagList.new.tap do |tag_list|
      tags = @tag_list.to_s.split(/[,;:|]/)

      tags.map! do |tag|
        tag.tr('#[]"?', '').strip
      end

      tags.reject!(&:empty?)

      tag_list.add tags
    end
  end
end
