class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :full_name
    add_index :tags, :tag_type
    add_index :references, :referenceable_id
    add_index :references, :referenceable_type
    add_index :reports, :reportable_id
    add_index :specialties, :name
    add_index :viewed_histories, :viewable_id
  end
end
