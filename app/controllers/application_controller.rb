class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Basic認証（管理画面用）
  before_action :authenticate_admin, if: :admin_path?

  # グローバルエラーハンドリング
  rescue_from StandardError, with: :handle_server_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::RoutingError, with: :handle_not_found

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

  # 404エラーハンドリング
  def handle_not_found(exception)
    logger.error "NotFound: #{exception.message}"
    respond_to do |format|
      format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
      format.json { render json: { error: "Not Found" }, status: :not_found }
    end
  end

  # 500エラーハンドリング
  def handle_server_error(exception)
    logger.error "ServerError: #{exception.class} - #{exception.message}"
    logger.error exception.backtrace.join("\n")

    # Railsロガーにも記録
    Rails.logger.error "ServerError: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html { render file: Rails.public_path.join("500.html"), status: :internal_server_error, layout: false }
      format.json { render json: { error: "Internal Server Error" }, status: :internal_server_error }
    end
  end
end
