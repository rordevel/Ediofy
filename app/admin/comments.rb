ActiveAdmin.register Comment do
  menu priority: 4
  permit_params do
    [:title, :comment, :status]
  end
  actions :index, :edit, :show
  index do
    id_column
    column :user
    column "Type" do |c|
      c.commentable_type
    end
    column "Title" do |c|
      c.commentable
    end
    column "Comment", class: "comment-field" do |c|
      c.comment.html_safe
    end
    column :status
    column :user_agent
    column :ip_address
    column :created_at   
    actions do |comment|
        item 'Spam', status_admin_comment_path(comment, status: 'spam'), class: 'member_link', method: 'put' if !comment.spam?
        item 'Trash', status_admin_comment_path(comment, status: 'trash'), class: 'member_link', method: 'put' if !comment.trash?
        item 'Pending', status_admin_comment_path(comment, status: 'pending'), class: 'member_link', method: 'put' if !comment.pending?
        item 'Approve', status_admin_comment_path(comment, status: 'approved'), class: 'member_link', method: 'put' if !comment.approved?
    end
  end
  member_action :status, method: :put do
    if resource.update_attribute("status", params[:status])
      redirect_to admin_comments_path, notice: "Comment status has been changed to #{resource.status}"
    else
      redirect_to admin_comments_path, notice: resource.errors
    end
  end
  filter :user
  filter :commentable_type, as: :select, label: "Type"
  filter :comment
  filter :status, as: :select, collection: Comment.statuses
  filter :created_at
end