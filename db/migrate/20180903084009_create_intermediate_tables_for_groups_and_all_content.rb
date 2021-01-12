class CreateIntermediateTablesForGroupsAndAllContent < ActiveRecord::Migration[5.0]
  def change
    create_table :groups_links do |t|
      t.belongs_to :link, index: true
      t.belongs_to :group, index: true
    end
    create_table :groups_media do |t|
      t.belongs_to :media, index: true
      t.belongs_to :group, index: true
    end
    create_table :groups_questions do |t|
      t.belongs_to :question, index: true
      t.belongs_to :group, index: true
    end
    create_table :conversations_groups do |t|
      t.belongs_to :conversation, index: true
      t.belongs_to :group, index: true
    end
  end
end
