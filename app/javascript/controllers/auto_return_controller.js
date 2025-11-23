import { Controller } from "@hotwired/stimulus"

// 自動リターンコントローラー
// 一定時間後に自動的に指定のURLにリダイレクトする
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 }, // デフォルト5秒
    url: { type: String, default: "/test_sheets/step1" } // デフォルトStep1
  }

  connect() {
    console.log("✅ AutoReturnController connected")
    console.log(`⏰ Redirect in ${this.timeoutValue}ms to ${this.urlValue}`)
    
    this.timeoutId = setTimeout(() => {
      console.log("🔄 Auto redirecting...")
      window.location.href = this.urlValue
    }, this.timeoutValue)
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      console.log("❌ AutoReturnController disconnected - timer cleared")
    }
  }

  // ユーザーが手動で別のアクションを取った場合にタイマーをキャンセル
  cancel() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      console.log("⛔ Auto return cancelled by user action")
    }
  }
}
