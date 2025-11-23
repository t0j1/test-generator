import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="kiosk-navigation"
export default class extends Controller {
  static targets = []

  connect() {
    console.log("KioskNavigationController connected")
  }

  selectSubject(event) {
    // Soft animation on selection
    const card = event.currentTarget
    card.style.transform = "scale(0.95)"
    setTimeout(() => {
      card.style.transform = "scale(1)"
    }, 150)
  }
}
