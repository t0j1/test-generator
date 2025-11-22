class ApplicationController < ActionController::Base
  # CSRF対策（Rails標準）
  # protect_from_forgery with: :exception はRails 7.1ではデフォルト

  # タイムゾーン設定
  around_action :set_time_zone

  private

  # タイムゾーンを日本時間に設定
  def set_time_zone(&block)
    Time.use_zone("Tokyo", &block)
  end
end
