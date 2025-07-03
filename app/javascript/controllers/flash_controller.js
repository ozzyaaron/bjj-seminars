import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Auto-dismiss flash messages after 5 seconds
    this.messageTargets.forEach((message) => {
      setTimeout(() => {
        this.dismissMessage(message)
      }, 5000)
    })
  }

  dismiss(event) {
    const message = event.currentTarget.closest("[data-flash-target='message']")
    this.dismissMessage(message)
  }

  dismissMessage(message) {
    message.style.opacity = "0"
    message.style.transform = "translateX(100%)"
    
    setTimeout(() => {
      message.remove()
    }, 300)
  }
}