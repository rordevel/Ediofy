ActiveAdmin.register MediaFile do
  menu parent: "Media"
  actions :index, :show
  config.clear_action_items!
  action_item :new, only: [:index] do
    link_to 'New Media', new_admin_media_index_path
  end
  index do
    id_column
    column :user
    column :title
    column :description, class: 'comment-field'
    column :media_type
    column :cached_votes_up
    column :cached_votes_down
    column :private
    column :created_at
    column :status
    actions
  end
  show do
    attributes_table do
      row :id
      row :user
      row :media_type
      row "File" do |m|
        if m.image?
          image_tag m.large_url
        elsif m.audio?
          audio_tag m.medium_url, controls: true
        elsif m.video?
          video_tag [m.video_url_mp4], controls: true, loop: true
        end
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
  filter :media_type, as: :select, collection: ["image", "audio", "video"]
  filter :title
  filter :description
  filter :cached_votes_up
  filter :cached_votes_down
  filter :private
  filter :created_at
  filter :status, as: :select, collection: MediaFile.statuses
end