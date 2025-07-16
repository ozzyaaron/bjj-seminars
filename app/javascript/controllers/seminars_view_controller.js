import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="seminars-view"
export default class extends Controller {
  static targets = ["grid"]
  static values = { 
    viewMode: { type: String, default: "grid" }
  }

  connect() {
    this.updateView()
  }

  setGridView() {
    this.viewModeValue = "grid"
  }

  setListView() {
    this.viewModeValue = "list"
  }

  viewModeValueChanged() {
    this.updateView()
    this.saveViewPreference()
  }

  updateView() {
    if (!this.hasGridTarget) return

    const gridContainer = this.gridTarget

    if (this.viewModeValue === "grid") {
      // Grid view classes
      gridContainer.className = "grid gap-6 sm:grid-cols-2 xl:grid-cols-3"
      
      // Update cards to use vertical layout
      const cards = gridContainer.querySelectorAll('[data-controller*="seminar-card"]')
      cards.forEach(card => {
        card.classList.remove('flex', 'flex-row')
        card.classList.add('flex-col')
      })
    } else {
      // List view classes
      gridContainer.className = "space-y-4"
      
      // Update cards to use horizontal layout
      const cards = gridContainer.querySelectorAll('[data-controller*="seminar-card"]')
      cards.forEach(card => {
        card.classList.remove('flex-col')
        card.classList.add('flex', 'flex-row')
      })
    }

    this.updateViewToggleButtons()
  }

  updateViewToggleButtons() {
    const buttons = this.element.querySelectorAll('[data-action*="seminars-view#set"]')
    
    buttons.forEach(button => {
      const isGridButton = button.dataset.action.includes('setGridView')
      const isActive = (isGridButton && this.viewModeValue === "grid") || 
                      (!isGridButton && this.viewModeValue === "list")
      
      if (isActive) {
        button.classList.remove('text-gray-400')
        button.classList.add('text-blue-600')
      } else {
        button.classList.remove('text-blue-600')
        button.classList.add('text-gray-400')
      }
    })
  }

  saveViewPreference() {
    // Save the view preference to localStorage
    try {
      localStorage.setItem('seminars-view-mode', this.viewModeValue)
    } catch (error) {
      console.warn('Could not save view preference:', error)
    }
  }

  loadViewPreference() {
    // Load the view preference from localStorage
    try {
      const savedView = localStorage.getItem('seminars-view-mode')
      if (savedView && ['grid', 'list'].includes(savedView)) {
        this.viewModeValue = savedView
      }
    } catch (error) {
      console.warn('Could not load view preference:', error)
    }
  }

  // Load preference when controller connects
  initialize() {
    this.loadViewPreference()
  }
}