ActiveAdmin.register ActivityKeyPointValue, as: "CPD" do
  # menu parent: "Badges", priority: 0
  permit_params [:activity_key, :point_value, :cpd_time, :category, :enabled]
  # actions :index, :edit, :update, :show
  index :title => "Grant points for every instance of these activities. Badges are awarded separately and can have their own point reward." do
    selectable_column
    id_column
    column "Activity Key" do |a|
      a.activity_key
    end
    column :point_value
    column :cpd_time
    column :category
    column :enabled
    actions
  end
  show do
    attributes_table do
      row "Activity Key" do |a|
        a.activity_key
      end
      row :point_value
      row :cpd_time
      row :category
      row :enabled
      row :created_at
      row :updated_at
    end
  end
  form do |f|
    f.inputs do
      f.input :activity_key
      f.input :point_value
      f.input :cpd_time
      f.input :category, as: :select, :collection => ActivityKeyPointValue::CATEGORIES
      f.input :enabled
    end
    f.actions
  end
  preserve_default_filters!
  filter :category, as: :select, collection: ActivityKeyPointValue::CATEGORIES
end
