ActiveAdmin.register User do
  menu priority: 1
  permit_params do
    permitted = [:first_name, :last_name, :email]
    permitted.push :password if params[:user] && !params[:user][:password].blank?
    permitted.push :password_confirmation if params[:user] && !params[:user][:password].blank?
    permitted
  end
  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :last_sign_in_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
  controller do
  protected
    def interpolation_options
      { user_password: resource.password }
    end
  end

  filter :first_name
  filter :last_name
  filter :email
end
