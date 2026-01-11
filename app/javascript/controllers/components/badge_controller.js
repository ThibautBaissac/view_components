import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="components--badge"
export default class extends Controller {
  dismiss() {
    // Dispatch custom event before removal
    this.element.dispatchEvent(new CustomEvent('badge:dismissed', {
      bubbles: true,
      detail: { text: this.element.textContent.trim() }
    }))

    // Fade out animation
    this.element.style.transition = "opacity 0.2s ease-out, transform 0.2s ease-out"
    this.element.style.opacity = "0"
    this.element.style.transform = "scale(0.8)"

    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, 200)
  }
}
