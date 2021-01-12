class FixTagDelimiters < ActiveRecord::Migration[5.1]
  def up
    Tag.where('name ~* ?', '[,;:|#\[\]"\?]').all.each do |old_tag|
      tags = old_tag.name.split(/[,;:|]/)
      tags.map! do |tag|
        tag.tr('#[]"?', '').strip
      end
      tags.reject!(&:empty?)

      if tags.empty?
        old_tag.destroy
        next
      end

      tags.each do |new_tag_name|
        new_tag = Tag.find_or_create_by(name: new_tag_name, tag_type: 0)

        ::ActsAsTaggableOn::Tagging.where(tag_id: old_tag.id).each do |tagging|
          new_tagging = tagging.dup
          new_tagging.tag_id = new_tag.id
          new_tagging.save
        end
      end

      ::ActsAsTaggableOn::Tagging.where(tag_id: old_tag.id).destroy_all
      old_tag.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
