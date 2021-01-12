class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.references :user
      t.references :reportable, polymorphic: true, index: true
      t.string :reason
      t.string :comments
      t.timestamps
    end
    add_column :questions, :status, :integer, default: 0
    add_column :media, :status, :integer, default: 0
    remove_column :questions, :site, :string
    remove_column :topics, :site, :string
  end
end
