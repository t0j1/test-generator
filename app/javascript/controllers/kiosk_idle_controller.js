import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="kiosk-idle"
// Auto-reset to landing page after inactivity (30 seconds)
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 30000 } // 30秒（デフォルト）
  }

  connect() {
    console.log("KioskIdleController connected")
    this.resetTimer()
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
    this.clearTimer()
  }

  addEventListeners() {
    this.resetTimerBound = this.resetTimer.bind(this)
    
    // Reset timer on any user interaction
    document.addEventListener("click", this.resetTimerBound)
    document.addEventListener("touchstart", this.resetTimerBound)
    document.addEventListener("keydown", this.resetTimerBound)
    document.addEventListener("scroll", this.resetTimerBound)
  }

  removeEventListeners() {
    document.removeEventListener("click", this.resetTimerBound)
    document.removeEventListener("touchstart", this.resetTimerBound)
    document.removeEventListener("keydown", this.resetTimerBound)
    document.removeEventListener("scroll", this.resetTimerBound)
  }

  resetTimer() {
    this.clearTimer()
    
    // Only set timer if not on landing page
    const isLandingPage = window.location.pathname === "/" || 
                          window.location.pathname === "/test_sheets/landing"
    
    if (!isLandingPage) {
      this.timerId = setTimeout(() => {
        this.returnToLanding()
      }, this.timeoutValue)
    }
  }

  clearTimer() {
    if (this.timerId) {
      clearTimeout(this.timerId)
      this.timerId = null
    }
  }

  returnToLanding() {
    console.log("Idle timeout - returning to landing page")
    window.location.href = "/"
  }
}
