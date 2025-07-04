import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-upload"
export default class extends Controller {
  static targets = ["input", "preview"]

  connect() {
    this.inputTarget.addEventListener('change', this.handleFileSelect.bind(this))
  }

  handleFileSelect(event) {
    const files = event.target.files
    this.clearPreview()
    
    if (files.length === 0) return
    
    // Validate file count
    if (files.length > 10) {
      alert('You can only upload up to 10 images')
      event.target.value = ''
      return
    }
    
    // Create preview container if it doesn't exist
    if (!this.hasPreviewTarget) {
      this.createPreviewContainer()
    }
    
    Array.from(files).forEach((file, index) => {
      if (this.isValidFile(file)) {
        this.createImagePreview(file, index)
      }
    })
  }

  isValidFile(file) {
    // Check file type
    const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
    if (!validTypes.includes(file.type)) {
      alert(`${file.name} is not a valid image format. Please use JPEG, PNG, or WebP.`)
      return false
    }
    
    // Check file size (5MB)
    if (file.size > 5 * 1024 * 1024) {
      alert(`${file.name} is too large. Maximum file size is 5MB.`)
      return false
    }
    
    return true
  }

  createPreviewContainer() {
    const container = document.createElement('div')
    container.className = 'mt-4'
    container.setAttribute('data-image-upload-target', 'preview')
    
    const title = document.createElement('h3')
    title.className = 'text-sm font-medium text-gray-700 mb-2'
    title.textContent = 'Image Preview'
    
    const grid = document.createElement('div')
    grid.className = 'grid grid-cols-2 md:grid-cols-4 gap-3'
    grid.setAttribute('data-preview-grid', '')
    
    container.appendChild(title)
    container.appendChild(grid)
    this.inputTarget.parentNode.appendChild(container)
  }

  createImagePreview(file, index) {
    const reader = new FileReader()
    
    reader.onload = (e) => {
      const previewDiv = document.createElement('div')
      previewDiv.className = 'relative'
      
      const img = document.createElement('img')
      img.src = e.target.result
      img.alt = `Preview ${index + 1}`
      img.className = 'w-full h-24 object-cover rounded-md border'
      
      const removeBtn = document.createElement('button')
      removeBtn.type = 'button'
      removeBtn.innerHTML = '×'
      removeBtn.className = 'absolute top-1 right-1 bg-red-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm hover:bg-red-600'
      removeBtn.addEventListener('click', () => {
        previewDiv.remove()
        this.removeFileFromInput(index)
      })
      
      previewDiv.appendChild(img)
      previewDiv.appendChild(removeBtn)
      
      const grid = this.element.querySelector('[data-preview-grid]')
      if (grid) {
        grid.appendChild(previewDiv)
      }
    }
    
    reader.readAsDataURL(file)
  }

  removeFileFromInput(indexToRemove) {
    // Note: This is a simplified approach. For full functionality,
    // you might want to use a more sophisticated file management system
    const input = this.inputTarget
    const files = Array.from(input.files)
    
    // Create new FileList without the removed file
    const dt = new DataTransfer()
    files.forEach((file, index) => {
      if (index !== indexToRemove) {
        dt.items.add(file)
      }
    })
    
    input.files = dt.files
  }

  clearPreview() {
    const preview = this.element.querySelector('[data-image-upload-target="preview"]')
    if (preview) {
      preview.remove()
    }
  }
}