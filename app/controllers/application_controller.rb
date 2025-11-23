class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Basic認証（管理画面用）
  before_action :authenticate_admin, if: :admin_path?

  private

  def admin_path?
    request.path.start_with?("/admin")
  end

  def authenticate_admin
    authenticate_or_request_with_http_basic("Admin Area") do |username, password|
      admin_user = ENV.fetch("ADMIN_USER", "admin")
      admin_password = ENV.fetch("ADMIN_PASSWORD", "password")
      
      ActiveSupport::SecurityUtils.secure_compare(username, admin_user) &&
        ActiveSupport::SecurityUtils.secure_compare(password, admin_password)
    end
  end
end
