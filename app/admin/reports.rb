ActiveAdmin.register Report do
  menu priority: 5
  actions :index
  index do
    id_column
    column "Content name" do |r|
      r.reportable
    end
    column "Content type" do |r|
      (r.reportable.class == Media) ? r.reportable.content_type : r.reportable_type unless r.reportable.blank?
    end
    column "Reported by" do |r|
      r.user
    end
    column "User who was reported" do |r|
      r.reportable.user unless r.reportable.blank?
    end
    column :reason
    column "Comments" do |r|
      r.comments
    end
    column "Status" do |r|
      r.reportable.status if !r.reportable.blank?
    end
    actions do |report|
      item 'Display', status_admin_report_path(report, status: 'displayed'), class: 'member_link', method: 'put' if !report.reportable.blank? && report.reportable.reported?
      item 'Remove', status_admin_report_path(report, status: 'removed'), class: 'member_link', method: 'put' if !report.reportable.blank? && report.reportable.displayed?
    end
  end
  member_action :status, method: :put do
    if resource.reportable.update_attribute("status", params[:status])
      # if resource.reportable.removed?
      #   resource.destroy
      # end
      redirect_to admin_reports_path, notice: "Content Status has been changed to #{resource.reportable.status}"
    else
      redirect_to admin_reports_path, notice: resource.errors
    end
  end
end