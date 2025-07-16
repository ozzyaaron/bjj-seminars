import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input"]
  static values = { 
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  performSearch() {
    // Clear any existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Debounce the search to avoid too many requests
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, this.debounceDelayValue)
  }

  submitForm() {
    // Submit the form with Turbo for smooth updates
    this.element.requestSubmit()
  }

  clear() {
    this.inputTarget.value = ""
    this.submitForm()
  }
}