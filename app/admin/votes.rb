ActiveAdmin.register Vote do
  menu parent: "Reports", priority: 1
  actions :index, :show, :destroy
  index do
    id_column
    column "Content Title" do |v|
      v.votable
    end
    column "Type" do |v|
      v.votable_type
    end
    column "Voted by" do |v|
      v.user
    end
    column "Vote" do |v|
      v.vote_flag ? "liked" : "disliked"
    end
    column :created_at
    actions
  end
  show do
    attributes_table do
      row "Type" do |v|
        v.votable_type
      end
      row "Title" do |v|
        v.votable
      end
      row "Voted by" do |v|
        v.user
      end
      row "Vote" do |v|
        v.vote_flag ? "liked" : "disliked"
      end
      row :created_at
    end
  end

  filter :votable_type, label: "Type"
  filter :votable, label: "Title", collection: -> {Vote.all.collect{ |v| v.votable }}
  filter :user, label: "voted By"
  filter :vote_flag, as: :select, label: "Vote", collection: [["Liked", true], ["Disliked",false]]
end