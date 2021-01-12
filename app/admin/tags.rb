ActiveAdmin.register Tag do
  menu parent: "Questions", priority: 1
  permit_params :name, :parent_id, :image, :tag_type
  form partial: 'form'
  index do
    selectable_column
    id_column
    column :name
    column :tag_type
    column :parent
    column "Image" do |i|
      image_tag i.image.medium.url unless i.image.blank?
    end
    actions
  end
  show do
    attributes_table do
      row :name
      row :tag_type
      row :parent
      row "Image" do |i|
        image_tag i.image.medium.url unless i.image.blank?
      end
      ul do
        unless tag.descendants.blank?
          tag.descendants.each do |c|
            li do 
              link_to c.name, edit_admin_tag_path(c)
            end
          end
        end
      end
    end
    # active_admin_comments
  end

  filter :name
  filter :tag_type
end