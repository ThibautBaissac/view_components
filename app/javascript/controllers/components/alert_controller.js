import { Controller } from "@hotwired/stimulus"

/**
 * Alert component controller for dismissible alerts.
 *
 * Handles dismissing alerts with smooth fade-out animation.
 * Includes proper error handling and cleanup to prevent memory leaks.
 *
 * Actions:
 * - dismiss: Fade out and remove the alert from the DOM
 *
 * @example Basic usage
 *   <div data-controller="components--alert">
 *     <button data-action="click->components--alert#dismiss">Dismiss</button>
 *   </div>
 *
 * @example With ARIA announcement
 *   <div data-controller="components--alert" role="alert" aria-live="polite">
 *     Alert content...
 *   </div>
 */
export default class extends Controller {
  /**
   * Dismiss the alert with a fade-out animation.
   * Includes error handling and ensures cleanup after animation completes.
   *
   * @param {Event} event - The click event (optional)
   */
  dismiss(event) {
    if (event) {
      event.preventDefault()
    }

    // Check if element exists and is still in the DOM
    if (!this.element || !this.element.parentNode) {
      console.warn("[AlertController] Alert element not found or already removed")
      return
    }

    try {
      // Fade out animation
      this.element.style.transition = "opacity 0.3s ease-out, transform 0.3s ease-out"
      this.element.style.opacity = "0"
      this.element.style.transform = "translateY(-8px)"

      // Remove element after animation
      this.animationTimeout = setTimeout(() => {
        if (this.element && this.element.parentNode) {
          this.element.remove()
        }
      }, 300)
    } catch (error) {
      console.error("[AlertController] Error dismissing alert:", error)
      // Fallback: remove immediately without animation
      if (this.element && this.element.parentNode) {
        this.element.remove()
      }
    }
  }

  /**
   * Clean up when controller is disconnected.
   * Clears any pending animation timeouts to prevent memory leaks.
   */
  disconnect() {
    if (this.animationTimeout) {
      clearTimeout(this.animationTimeout)
      this.animationTimeout = null
    }
  }
}
