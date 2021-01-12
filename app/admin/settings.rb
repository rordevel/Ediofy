ActiveAdmin.register Setting do
  menu priority: 8
  actions :index, :show
  index do
    selectable_column
    id_column
    column :user
    column :privacy_public do |s|
      b t("formtastic.labels.setting.privacy_public_#{s.privacy_public}")
      br
      span t("formtastic.hints.setting.privacy_public_#{s.privacy_public}")
    end
    column :privacy_friends do |s|
      b t("formtastic.labels.setting.privacy_friends_#{s.privacy_friends}")
      br
      span t("formtastic.hints.setting.privacy_friends_#{s.privacy_friends}")
    end
    column :question_reset_date
    column :question_reset
    column :send_updates
    actions
  end
  # form do |f|
  #   f.inputs t('.privacy') do
  #     f.input :privacy_friends, :as => :hinted_radio, :collection => (1..3)
  #     f.input :privacy_public, :as => :hinted_radio, :collection => (1..3)
  #   end
  #   f.actions
  # end
  show do
    attributes_table do
      row :id
      row :user
      row :privacy_public do |s|
        b t("formtastic.labels.setting.privacy_public_#{s.privacy_public}")
        br
        span t("formtastic.hints.setting.privacy_public_#{s.privacy_public}")
      end
      row :privacy_friends do |s|
        b t("formtastic.labels.setting.privacy_friends_#{s.privacy_friends}")
        br
        span t("formtastic.hints.setting.privacy_friends_#{s.privacy_friends}")
      end
      row :question_reset_date
      row :question_reset
      row :send_updates
      active_admin_comments
    end
  end

  filter :user
  filter :privacy_public, as: :select, collection: [["Open", 1], ["Medium",2], ["Stealth",3]]
  filter :privacy_friends, as: :select, collection: [["Open", 1], ["Medium",2], ["Stealth",3]]
  filter :question_reset_date
  filter :question_reset, as: :select
  filter :send_updates
end