ActiveAdmin.register Media do
  menu priority: 3
  permit_params :user_id, :title, :description, :file, :private, media_attributes: [:id, :title, :description, :tags_list, :file, :_destroy]
  index do
    id_column
    column :user
    # column :media_type
    column :title
    column :description, class: 'comment-field'
    column :cached_votes_up
    column :cached_votes_down
    column :private
    column :created_at
    column :status
    actions
  end
  form do |f|
    f.inputs do
      f.input :user
      f.input :title
      f.input :description
      f.input :private, as: :radio, collection: [[t('public', scope: 'ediofy.media'), false], [t('private', scope: 'ediofy.media'), true]]
      # f.input :file, as: :file, :hint => f.object.file.blank? ? "" : form_file_hint_helper(f.object.file) unless resource.new_record?
      f.has_many :media_files do |m|
        m.input :file, as: :file, :hint => form_file_hint_helper(m.object.file)
      end
    end
    f.actions
  end
  show do
    attributes_table do
      row :id
      row :user
      # row :media_type
      row :title
      row :description, class: 'comment-field'
      row "File" do |m|
        m.media_files.map do |mf|
          if mf.image?
            image_tag mf.large_url
          elsif mf.audio?
            audio_tag mf.medium_url, controls: true
          elsif mf.video?
            video_tag [mf.video_url_mp4], controls: true, loop: true
          end
        end.join('<br>').html_safe
      end
      row :cached_votes_up
      row :cached_votes_down
      row :private
      row :created_at
      row :status
      panel "Tags" do
        table_for resource.tags do
          column :name
        end
      end
      panel "Comments" do
        table_for resource.comments do
          column :user
          column :comment
          column :created_at
        end
      end
    end
  end
  filter :user
  # filter :media_type, as: :select, collection: ["image", "audio", "video"]
  filter :title
  filter :description
  filter :cached_votes_up
  filter :cached_votes_down
  filter :private
  filter :created_at

  controller do
    # def scoped_collection
    #   Media.unscoped
    # end
  end
end