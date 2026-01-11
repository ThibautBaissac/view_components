import { Controller } from "@hotwired/stimulus"

/**
 * Switch Component Controller
 *
 * Enhances the SwitchComponent with advanced interactions such as:
 * - Confirmation dialogs for critical toggles
 * - Custom event dispatching for analytics and integrations
 * - Optimistic UI updates with Turbo integration
 *
 * @example Basic usage
 *   <div data-controller="components--switch">
 *     <%= render Form::Field::SwitchComponent.new(...) %>
 *   </div>
 *
 * @example With confirmation dialog
 *   <div data-controller="components--switch"
 *        data-components--switch-confirm-value="Are you sure?">
 *     <%= render Form::Field::SwitchComponent.new(...) %>
 *   </div>
 *
 * @example With custom event handling
 *   <div data-controller="components--switch analytics"
 *        data-action="switch:toggled->analytics#track">
 *     <%= render Form::Field::SwitchComponent.new(...) %>
 *   </div>
 *
 * Values:
 * - confirm: String - Optional confirmation message before toggle
 *
 * Actions:
 * - toggle: Handle switch state changes
 *
 * Events Dispatched:
 * - switch:toggled - { detail: { checked: Boolean, value: String } }
 * - switch:confirmed - { detail: { confirmed: Boolean } }
 */
export default class extends Controller {
  static values = {
    confirm: String
  }

  static targets = ["input"]

  /**
   * Handle switch toggle with optional confirmation
   */
  toggle(event) {
    const input = event.target
    const checked = input.checked

    // If confirmation is required and user cancels, revert the state
    if (this.hasConfirmValue) {
      if (!confirm(this.confirmValue)) {
        event.preventDefault()
        input.checked = !checked

        this.dispatch("confirmed", {
          detail: { confirmed: false }
        })
        return
      }

      this.dispatch("confirmed", {
        detail: { confirmed: true }
      })
    }

    // Dispatch custom event for other controllers to listen
    this.dispatch("toggled", {
      detail: {
        checked: checked,
        value: input.value,
        name: input.name
      }
    })
  }

  /**
   * Get the switch input element
   * @returns {HTMLInputElement}
   */
  get input() {
    return this.hasInputTarget
      ? this.inputTarget
      : this.element.querySelector('input[type="checkbox"]')
  }

  /**
   * Get current switch state
   * @returns {Boolean}
   */
  get checked() {
    return this.input?.checked || false
  }

  /**
   * Set switch state programmatically
   * @param {Boolean} value
   */
  set checked(value) {
    if (this.input) {
      this.input.checked = Boolean(value)
      this.dispatch("toggled", {
        detail: {
          checked: Boolean(value),
          value: this.input.value,
          name: this.input.name
        }
      })
    }
  }
}
