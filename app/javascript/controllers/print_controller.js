import { Controller } from "@hotwired/stimulus"

// 印刷実行とログ記録
export default class extends Controller {
  connect() {
    console.log("PrintController connected")
  }

  // すべて印刷（問題用紙 + 解答用紙）
  async executeAll(event) {
    event.preventDefault()
    
    // 印刷モードをリセット
    document.body.classList.remove('print-questions-only', 'print-answers-only')
    
    console.log("🖨️ すべて印刷: 問題用紙 + 解答用紙")
    
    window.print()
    
    await this.markAsPrinted()
  }

  // 問題のみ印刷
  async executeQuestions(event) {
    event.preventDefault()
    
    // 問題のみモードを設定
    document.body.classList.add('print-questions-only')
    document.body.classList.remove('print-answers-only')
    
    console.log("📝 問題のみ印刷")
    
    window.print()
    
    // 印刷後、クラスをリセット
    setTimeout(() => {
      document.body.classList.remove('print-questions-only')
    }, 100)
    
    await this.markAsPrinted()
  }

  // 解答のみ印刷
  async executeAnswers(event) {
    event.preventDefault()
    
    // 解答のみモードを設定
    document.body.classList.add('print-answers-only')
    document.body.classList.remove('print-questions-only')
    
    console.log("✅ 解答のみ印刷")
    
    window.print()
    
    // 印刷後、クラスをリセット
    setTimeout(() => {
      document.body.classList.remove('print-answers-only')
    }, 100)
    
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
