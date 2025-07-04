import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-modal"
export default class extends Controller {
  connect() {
    this.element.addEventListener('click', this.openModal.bind(this))
  }

  openModal(event) {
    event.preventDefault()
    
    const img = this.element.querySelector('img')
    if (!img) return
    
    // Create modal overlay
    const overlay = document.createElement('div')
    overlay.className = 'fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4'
    overlay.addEventListener('click', () => overlay.remove())
    
    // Create modal content
    const modalContent = document.createElement('div')
    modalContent.className = 'relative max-w-4xl max-h-full'
    modalContent.addEventListener('click', (e) => e.stopPropagation())
    
    // Create larger image
    const modalImg = document.createElement('img')
    modalImg.src = img.src
    modalImg.alt = img.alt
    modalImg.className = 'max-w-full max-h-full object-contain rounded-lg'
    
    // Create close button
    const closeBtn = document.createElement('button')
    closeBtn.innerHTML = '×'
    closeBtn.className = 'absolute top-2 right-2 text-white text-3xl font-bold bg-black bg-opacity-50 rounded-full w-10 h-10 flex items-center justify-center hover:bg-opacity-75'
    closeBtn.addEventListener('click', () => overlay.remove())
    
    modalContent.appendChild(modalImg)
    modalContent.appendChild(closeBtn)
    overlay.appendChild(modalContent)
    document.body.appendChild(overlay)
    
    // Close on escape key
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        overlay.remove()
        document.removeEventListener('keydown', handleEscape)
      }
    }
    document.addEventListener('keydown', handleEscape)
  }
}