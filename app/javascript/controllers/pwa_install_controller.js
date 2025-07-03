import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pwa-install"
export default class extends Controller {
  connect() {
    this.deferredPrompt = null
    
    window.addEventListener('beforeinstallprompt', (e) => {
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault()
      // Stash the event so it can be triggered later
      this.deferredPrompt = e
      // Show the install button
      this.element.classList.remove('hidden')
    })

    window.addEventListener('appinstalled', () => {
      // Hide the install button
      this.element.classList.add('hidden')
      this.deferredPrompt = null
    })
  }

  async install() {
    if (!this.deferredPrompt) {
      return
    }

    // Show the install prompt
    this.deferredPrompt.prompt()

    // Wait for the user to respond to the prompt
    const { outcome } = await this.deferredPrompt.userChoice

    // We've used the prompt, and can't use it again, throw it away
    this.deferredPrompt = null

    // Hide the install button regardless of outcome
    this.element.classList.add('hidden')
  }
}