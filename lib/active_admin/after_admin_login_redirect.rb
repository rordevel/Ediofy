module ActiveAdmin
  module AfterAdminLoginRedirect
    extend ActiveSupport::Concern

    protected
    def after_sign_in_path_for(resource)
      session[:admin_return_to] || super
    end
  end
end