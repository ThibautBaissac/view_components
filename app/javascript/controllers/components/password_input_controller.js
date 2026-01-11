import { Controller } from "@hotwired/stimulus"

/**
 * Password Input Controller
 *
 * Toggles password visibility between hidden (password) and visible (text) states.
 *
 * Targets:
 * - input: The password input field
 * - toggleButton: The toggle button element
 * - showIcon: The icon shown when password is hidden (eye icon)
 * - hideIcon: The icon shown when password is visible (eye-slash icon)
 *
 * Usage:
 *   <div data-controller="components--password-input">
 *     <input type="password" data-components--password-input-target="input">
 *     <button data-action="click->components--password-input#toggle"
 *             data-components--password-input-target="toggleButton">
 *       <span data-components--password-input-target="showIcon">👁️</span>
 *       <span data-components--password-input-target="hideIcon" class="hidden">👁️‍🗨️</span>
 *     </button>
 *   </div>
 */
export default class extends Controller {
  static targets = ["input", "toggleButton", "showIcon", "hideIcon"]

  /**
   * Toggle password visibility
   */
  toggle() {
    const input = this.inputTarget
    const isPassword = input.type === "password"

    // Toggle input type
    input.type = isPassword ? "text" : "password"

    // Toggle icons
    this.showIconTarget.classList.toggle("hidden")
    this.hideIconTarget.classList.toggle("hidden")

    // Update button aria-label (using I18n labels from data attributes)
    const newLabel = isPassword
      ? this.toggleButtonTarget.dataset.hideLabel
      : this.toggleButtonTarget.dataset.showLabel
    this.toggleButtonTarget.setAttribute("aria-label", newLabel)

    // Maintain focus on input
    input.focus()
  }
}
