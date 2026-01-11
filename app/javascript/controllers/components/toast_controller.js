import { Controller } from "@hotwired/stimulus"

/**
 * Toast Controller
 *
 * Manages toast notification behavior including auto-dismiss, progress bar animation,
 * and manual dismissal. Toasts can optionally auto-dismiss after a configurable timeout.
 *
 * Targets:
 * - progressBar: Optional progress bar element that animates during countdown
 *
 * Values:
 * - timeout: Number of milliseconds before auto-dismiss (default: 5000)
 * - autoDismiss: Whether to auto-dismiss the toast (default: true)
 *
 * Usage:
 *   <div data-controller="components--toast"
 *        data-components--toast-timeout-value="5000"
 *        data-components--toast-auto-dismiss-value="true">
 *     Toast content...
 *     <button data-action="click->components--toast#dismiss">×</button>
 *     <div data-components--toast-target="progressBar"></div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["progressBar", "toast"]
  static values = {
    timeout: { type: Number, default: 5000 },
    autoDismiss: { type: Boolean, default: true }
  }
  static DISMISS_ANIMATION_DURATION = 300

  connect() {
    // Start auto-dismiss countdown if enabled
    if (this.autoDismissValue && this.timeoutValue > 0) {
      this.startCountdown()
    }
  }

  disconnect() {
    this.clearCountdown()
    this.pausedWidth = undefined
  }

  startCountdown() {
    // Animate progress bar
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.transition = `width ${this.timeoutValue}ms linear`
      requestAnimationFrame(() => {
        this.progressBarTarget.style.width = "0%"
      })
    }

    // Set timeout for auto-dismiss
    this.dismissTimeout = setTimeout(() => {
      this.dismiss()
    }, this.timeoutValue)
  }

  clearCountdown() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      this.dismissTimeout = null
    }
  }

  // Pause countdown on hover
  pause() {
    this.clearCountdown()

    if (this.hasProgressBarTarget) {
      // Get current width and pause animation
      const computedStyle = window.getComputedStyle(this.progressBarTarget)
      const currentWidth = computedStyle.width
      this.progressBarTarget.style.transition = "none"
      this.progressBarTarget.style.width = currentWidth
      this.pausedWidth = parseFloat(currentWidth) / this.progressBarTarget.parentElement.offsetWidth * 100
    }
  }

  // Resume countdown after hover
  resume() {
    if (!this.autoDismissValue || this.timeoutValue <= 0) return

    if (this.hasProgressBarTarget && this.pausedWidth !== undefined) {
      // Calculate remaining time based on progress bar width
      const remainingTime = (this.pausedWidth / 100) * this.timeoutValue

      this.progressBarTarget.style.transition = `width ${remainingTime}ms linear`
      requestAnimationFrame(() => {
        this.progressBarTarget.style.width = "0%"
      })

      this.dismissTimeout = setTimeout(() => {
        this.dismiss()
      }, remainingTime)
    }
  }

  dismiss() {
    this.clearCountdown()

    // Fade out animation
    this.element.style.transition = "opacity 0.3s ease-out, transform 0.3s ease-out"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateX(100%)"

    // Remove element after animation
    setTimeout(() => {
      this.element.remove()
    }, this.constructor.DISMISS_ANIMATION_DURATION)
  }
}
