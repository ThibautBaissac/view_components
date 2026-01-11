import { Controller } from "@hotwired/stimulus"

/**
 * Date Picker Controller
 *
 * Handles enhanced functionality for the date picker component,
 * including clear button visibility and clearing the date value.
 *
 * Targets:
 * - input: The date input element
 * - clearButton: The clear button element
 *
 * Actions:
 * - clear: Clears the date value and hides the clear button
 */
export default class extends Controller {
  static targets = ["input", "clearButton"]

  connect() {
    this.updateClearButtonVisibility()
  }

  /**
   * Clear the date value
   * @param {Event} event - The click event
   */
  clear(event) {
    event.preventDefault()

    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
      this.updateClearButtonVisibility()

      // Dispatch change event for form integration
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    }
  }

  /**
   * Handle input changes to update clear button visibility
   */
  handleInput() {
    this.updateClearButtonVisibility()
  }

  /**
   * Update the clear button visibility based on input value
   */
  updateClearButtonVisibility() {
    if (!this.hasClearButtonTarget) return

    const hasValue = this.hasInputTarget && this.inputTarget.value !== ""

    if (hasValue) {
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.clearButtonTarget.classList.add("hidden")
    }
  }
}
