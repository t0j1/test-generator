require "test_helper"
require "capybara/rails"
require "capybara/minitest"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--remote-debugging-port=9222')
    
    # ブラウザログを有効化（デバッグ用）
    options.logging_prefs = { browser: 'ALL' }
  end

  # テスト実行前のセットアップ
  setup do
    # JavaScriptエラーを検出
    Capybara.raise_server_errors = false
  end
  
  # ブラウザコンソールログを出力（デバッグ用）
  def print_browser_logs
    return unless respond_to?(:page)
    
    begin
      logs = page.driver.browser.logs.get(:browser)
      return if logs.empty?
      
      puts "\n📋 Browser Console Logs:"
      logs.each do |log|
        puts "  [#{log.level}] #{log.message}"
      end
    rescue StandardError => e
      puts "⚠️ Could not retrieve browser logs: #{e.message}"
    end
  end
  
  # テスト実行後のクリーンアップ
  teardown do
    # デバッグ用にブラウザログを出力
    # print_browser_logs if ENV['DEBUG']
  end
end
