import { Controller } from "@hotwired/stimulus"

/**
 * Conversion Modal Controller
 *
 * Manages the conversion modal for converting leads to events.
 * Handles modal open/close, focus trapping, and accessibility.
 *
 * Targets:
 *   - modal: The modal container element
 *   - firstFocusable: First focusable element for tab trapping
 *   - lastFocusable: Last focusable element for tab trapping
 *
 * Actions:
 *   - open(): Opens the modal
 *   - close(): Closes the modal
 *   - handleKeydown(event): Handles ESC key to close modal
 *   - trapFocus(event): Traps focus within modal
 *
 * Usage:
 *   <div data-controller="components--conversion-modal">
 *     <button data-action="click->components--conversion-modal#open">
 *       Convert to Event
 *     </button>
 *     <div data-components--conversion-modal-target="modal">
 *       <!-- Modal content -->
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["modal", "firstFocusable", "lastFocusable"]

  /**
   * Opens the modal and sets up event listeners
   */
  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"

    // Focus first focusable element
    if (this.hasFirstFocusableTarget) {
      this.firstFocusableTarget.focus()
    }

    // Add event listeners
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.boundTrapFocus = this.trapFocus.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
    this.modalTarget.addEventListener("keydown", this.boundTrapFocus)
  }

  /**
   * Closes the modal and removes event listeners
   */
  close() {
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""

    // Remove event listeners
    if (this.boundHandleKeydown) {
      document.removeEventListener("keydown", this.boundHandleKeydown)
    }
    if (this.boundTrapFocus) {
      this.modalTarget.removeEventListener("keydown", this.boundTrapFocus)
    }
  }

  /**
   * Handles keydown events for ESC key
   * @param {KeyboardEvent} event - The keyboard event
   */
  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  /**
   * Traps focus within the modal
   * Prevents tabbing outside the modal by cycling between first and last focusable elements
   * @param {KeyboardEvent} event - The keyboard event
   */
  trapFocus(event) {
    if (event.key !== "Tab") return

    if (!this.hasFirstFocusableTarget || !this.hasLastFocusableTarget) return

    // If shift+tab on first element, focus last
    if (event.shiftKey && document.activeElement === this.firstFocusableTarget) {
      event.preventDefault()
      this.lastFocusableTarget.focus()
    }
    // If tab on last element, focus first
    else if (!event.shiftKey && document.activeElement === this.lastFocusableTarget) {
      event.preventDefault()
      this.firstFocusableTarget.focus()
    }
  }

  /**
   * Cleanup when controller disconnects
   */
  disconnect() {
    this.close()
  }
}
