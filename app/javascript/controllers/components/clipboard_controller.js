import { Controller } from "@hotwired/stimulus"

/**
 * Clipboard Controller
 *
 * Handles copying text to clipboard with visual feedback.
 *
 * Targets:
 * - source: Hidden input containing the value to copy
 * - button: The trigger button (for disabling during feedback)
 * - icon: The copy icon element
 * - successIcon: The success checkmark icon element
 * - text: The button text element
 * - successText: The success text element
 * - announcement: Screen reader announcement element
 *
 * Values:
 * - successText: Text to display in the button (default: "Copied to clipboard")
 * - successAnnouncement: Text to announce to screen readers on success (default: "Copied to clipboard")
 * - errorAnnouncement: Text to announce to screen readers on error (default: "Failed to copy to clipboard")
 * - successDuration: How long to show success state in ms (default: 2000)
 * - debounceDelay: Minimum time between copy operations in ms (default: 300)
 */
export default class extends Controller {
  static targets = ["source", "button", "icon", "successIcon", "text", "successText", "announcement"]
  static values = {
    successText: { type: String, default: "Copied to clipboard" },
    successAnnouncement: { type: String, default: "Copied to clipboard" },
    errorAnnouncement: { type: String, default: "Failed to copy to clipboard" },
    successDuration: { type: Number, default: 2000 },
    debounceDelay: { type: Number, default: 300 }
  }

  connect() {
    this.resetTimeout = null
    this.debounceTimeout = null
    this.isCopying = false
    this.lastCopyTime = 0
  }

  disconnect() {
    if (this.resetTimeout) {
      clearTimeout(this.resetTimeout)
    }
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
  }

  async copy(event) {
    event.preventDefault()

    // Debounce: prevent rapid-fire copying
    const now = Date.now()
    if (now - this.lastCopyTime < this.debounceDelayValue) {
      return
    }
    this.lastCopyTime = now

    // Prevent overlapping copy operations during feedback animation
    if (this.isCopying) return
    this.isCopying = true

    const text = this.sourceTarget.value

    try {
      await navigator.clipboard.writeText(text)
      this.showSuccess()
    } catch (err) {
      // Fallback for older browsers or when clipboard API is not available
      this.fallbackCopy(text)
    }
  }

  fallbackCopy(text) {
    // Create a temporary textarea element
    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.style.position = "fixed"
    textarea.style.left = "-9999px"
    textarea.style.top = "-9999px"
    textarea.setAttribute("readonly", "")
    document.body.appendChild(textarea)

    textarea.select()
    textarea.setSelectionRange(0, text.length)

    try {
      const successful = document.execCommand("copy")
      if (successful) {
        this.showSuccess()
      } else {
        this.showError()
      }
    } catch (err) {
      this.showError()
    } finally {
      document.body.removeChild(textarea)
    }
  }

  showSuccess() {
    // Clear any existing timeout
    if (this.resetTimeout) {
      clearTimeout(this.resetTimeout)
    }

    // Toggle icon visibility
    if (this.hasIconTarget && this.hasSuccessIconTarget) {
      this.iconTarget.classList.add("hidden")
      this.successIconTarget.classList.remove("hidden")
    }

    // Toggle text visibility
    if (this.hasTextTarget && this.hasSuccessTextTarget) {
      this.textTarget.classList.add("hidden")
      this.successTextTarget.classList.remove("hidden")
    }

    // Announce to screen readers
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = this.successAnnouncementValue
    }

    // Dispatch custom event
    this.dispatch("copied", { detail: { text: this.sourceTarget.value } })

    // Reset after duration
    this.resetTimeout = setTimeout(() => {
      this.reset()
    }, this.successDurationValue)
  }

  showError() {
    // Announce error to screen readers
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = this.errorAnnouncementValue
    }

    // Dispatch custom event
    this.dispatch("error")
  }

  reset() {
    this.isCopying = false

    // Toggle icon visibility back
    if (this.hasIconTarget && this.hasSuccessIconTarget) {
      this.iconTarget.classList.remove("hidden")
      this.successIconTarget.classList.add("hidden")
    }

    // Toggle text visibility back
    if (this.hasTextTarget && this.hasSuccessTextTarget) {
      this.textTarget.classList.remove("hidden")
      this.successTextTarget.classList.add("hidden")
    }

    // Clear announcement
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = ""
    }
  }
}
