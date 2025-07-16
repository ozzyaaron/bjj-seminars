import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filter-panel"
export default class extends Controller {
  static targets = ["form"]
  static values = { 
    debounceDelay: { type: Number, default: 500 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  applyFilters() {
    // Clear any existing timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Debounce the filtering to avoid too many requests
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, this.debounceDelayValue)
  }

  submitForm() {
    // Submit the form with Turbo for smooth updates
    this.formTarget.requestSubmit()
  }

  clearAll() {
    // Clear all form inputs
    const inputs = this.formTarget.querySelectorAll('input[type="text"], input[type="number"], input[type="date"]')
    inputs.forEach(input => {
      input.value = ""
    })

    // Uncheck all checkboxes
    const checkboxes = this.formTarget.querySelectorAll('input[type="checkbox"]')
    checkboxes.forEach(checkbox => {
      checkbox.checked = false
    })

    // Submit the cleared form
    this.submitForm()
  }

  toggleInstructor(event) {
    event.preventDefault()
    
    const instructorName = event.currentTarget.dataset.instructor
    const instructorInput = this.formTarget.querySelector('input[name="instructor"]')
    
    if (instructorInput) {
      // Toggle the instructor name in the input
      if (instructorInput.value === instructorName) {
        instructorInput.value = ""
      } else {
        instructorInput.value = instructorName
      }
      
      // Update the visual state of the pill
      this.updateInstructorPills(instructorName)
      
      // Apply the filter
      this.applyFilters()
    }
  }

  updateInstructorPills(selectedInstructor) {
    const pills = this.formTarget.querySelectorAll('[data-instructor]')
    
    pills.forEach(pill => {
      const instructor = pill.dataset.instructor
      const isSelected = instructor === selectedInstructor
      
      if (isSelected) {
        pill.classList.remove('bg-gray-100', 'text-gray-700', 'border-gray-300')
        pill.classList.add('bg-blue-100', 'text-blue-800', 'border-blue-300')
      } else {
        pill.classList.remove('bg-blue-100', 'text-blue-800', 'border-blue-300')
        pill.classList.add('bg-gray-100', 'text-gray-700', 'border-gray-300')
      }
    })
  }
}