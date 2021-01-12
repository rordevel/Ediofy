class AddTextsearchCacheToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :textsearch_cache, :text

    Group.all.each(&:touch)
  end
end
