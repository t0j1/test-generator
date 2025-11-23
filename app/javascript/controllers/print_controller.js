import { Controller } from "@hotwired/stimulus"

// 印刷実行とログ記録
export default class extends Controller {
  connect() {
    console.log("PrintController connected")
  }

  // 印刷実行
  async executeAll(event) {
    event.preventDefault()
    
    console.log("🖨️ テスト用紙を印刷")
    
    window.print()
    
    await this.markAsPrinted()
  }

  // 印刷済みマークをサーバーに記録
  async markAsPrinted() {
    const testSheetId = this.getTestSheetId()
    
    if (!testSheetId) {
      console.error("Test sheet ID not found")
      return
    }

    try {
      const response = await fetch(`/test_sheets/${testSheetId}/mark_printed`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCsrfToken()
        }
      })

      if (!response.ok) {
        throw new Error('Failed to mark as printed')
      }

      const data = await response.json()
      console.log("✅ Marked as printed:", data)
      
    } catch (error) {
      console.error("❌ Failed to mark as printed:", error)
    }
  }

  // URLからテストシートIDを取得
  getTestSheetId() {
    const pathMatch = window.location.pathname.match(/\/test_sheets\/(\d+)/)
    return pathMatch ? pathMatch[1] : null
  }

  // CSRFトークンを取得
  getCsrfToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ''
  }


}
