import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="seminar-card"
export default class extends Controller {
  static values = { 
    favorited: { type: Boolean, default: false }
  }

  connect() {
    this.updateFavoriteIcon()
  }

  toggleFavorite(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const seminarId = event.currentTarget.dataset.seminarId
    
    if (!seminarId) {
      console.error("No seminar ID found")
      return
    }

    // Toggle the favorited state
    this.favoritedValue = !this.favoritedValue
    
    // Update the icon immediately for responsive feedback
    this.updateFavoriteIcon()
    
    // Send the request to the server
    this.sendFavoriteRequest(seminarId, this.favoritedValue)
  }

  favoritedValueChanged() {
    this.updateFavoriteIcon()
  }

  updateFavoriteIcon() {
    const favoriteButton = this.element.querySelector('[data-action*="toggleFavorite"]')
    const heartIcon = favoriteButton?.querySelector('svg')
    
    if (!heartIcon) return

    if (this.favoritedValue) {
      heartIcon.classList.remove('text-gray-600')
      heartIcon.classList.add('text-red-500')
      heartIcon.setAttribute('fill', 'currentColor')
    } else {
      heartIcon.classList.remove('text-red-500')
      heartIcon.classList.add('text-gray-600')
      heartIcon.setAttribute('fill', 'none')
    }
  }

  async sendFavoriteRequest(seminarId, favorited) {
    try {
      const response = await fetch(`/seminars/${seminarId}/favorite`, {
        method: favorited ? 'POST' : 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        // Revert the state if the request failed
        this.favoritedValue = !this.favoritedValue
        console.error('Failed to update favorite status')
      }
    } catch (error) {
      // Revert the state if the request failed
      this.favoritedValue = !this.favoritedValue
      console.error('Error updating favorite status:', error)
    }
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }
}