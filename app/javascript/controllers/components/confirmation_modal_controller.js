import { Controller } from "@hotwired/stimulus"

/**
 * Confirmation Modal Controller
 *
 * Extends the base modal functionality with confirmation-specific behavior
 * such as Enter key to confirm and dispatching confirmation events.
 *
 * Targets:
 * - confirmButton: The confirm action button
 *
 * Actions:
 * - confirm: Triggers the confirmation action
 * - confirmOnEnter: Confirms when Enter key is pressed
 *
 * Events:
 * - confirmation-modal:confirm - Dispatched when user confirms
 * - confirmation-modal:cancel - Dispatched when user cancels
 *
 * @example
 * <div data-controller="components--confirmation-modal"
 *      data-action="keydown.enter->components--confirmation-modal#confirmOnEnter">
 *   <button data-action="click->components--confirmation-modal#confirm"
 *           data-components--confirmation-modal-target="confirmButton">
 *     Confirm
 *   </button>
 * </div>
 */
export default class extends Controller {
  static targets = ["confirmButton"]

  connect() {
    // Listen for modal close to dispatch cancel event
    this.boundHandleModalClose = this.handleModalClose.bind(this)
    this.element.addEventListener("components--modal:close", this.boundHandleModalClose)
  }

  disconnect() {
    this.element.removeEventListener("components--modal:close", this.boundHandleModalClose)
  }

  /**
   * Confirms the action
   * @param {Event} [event] - Optional event
   */
  confirm(event) {
    if (event) {
      event.preventDefault()
    }

    // Check if element exists
    if (!this.element || !this.element.parentNode) {
      console.warn("[ConfirmationModal] Modal element not found or already removed")
      return
    }

    // Check if confirm button is disabled
    if (this.hasConfirmButtonTarget && this.confirmButtonTarget.disabled) {
      return
    }

    try {
      // Dispatch confirm event with modal details
      this.dispatch("confirm", {
        detail: {
          modal: this.element,
          confirmed: true
        }
      })

      // Close the modal
      this.closeModal()
    } catch (error) {
      console.error("[ConfirmationModal] Error confirming action:", error)
    }
  }

  /**
   * Handles Enter key to confirm
   * @param {KeyboardEvent} event - Keyboard event
   */
  confirmOnEnter(event) {
    // Only confirm on Enter if not in a form field
    const activeElement = document.activeElement
    const isFormField = activeElement.matches("input, textarea, select")

    if (!isFormField) {
      event.preventDefault()
      this.confirm()
    }
  }

  /**
   * Handles modal close event to dispatch cancel
   * @param {CustomEvent} event - Modal close event
   */
  handleModalClose(event) {
    try {
      // Only dispatch cancel if not already confirmed
      if (!this.confirmed) {
        this.dispatch("cancel", {
          detail: {
            modal: this.element,
            confirmed: false
          }
        })
      }

      // Reset state
      this.confirmed = false
    } catch (error) {
      console.error("[ConfirmationModal] Error handling modal close:", error)
      // Reset state even on error
      this.confirmed = false
    }
  }

  /**
   * Closes the parent modal
   */
  closeModal() {
    try {
      this.confirmed = true

      // Check if element exists
      if (!this.element || !this.element.parentNode) {
        console.warn("[ConfirmationModal] Cannot close modal, element not found")
        return
      }

      // Find the dialog element and close it
      const dialog = this.element.closest("dialog")
      if (dialog) {
        dialog.close()
      }
    } catch (error) {
      console.error("[ConfirmationModal] Error closing modal:", error)
    }
  }
}
