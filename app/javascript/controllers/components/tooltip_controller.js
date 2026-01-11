import { Controller } from "@hotwired/stimulus"

/**
 * Tooltip Controller
 *
 * Handles tooltip display on hover, focus, and touch with configurable delay.
 * Provides comprehensive accessibility support with ARIA attributes, keyboard
 * navigation (ESC to close), and screen reader compatibility.
 *
 * The controller manages tooltip visibility based on user interaction, including
 * mouse hover, keyboard focus, and touch events. It automatically handles ARIA
 * state updates and dispatches custom events for integration with other components.
 *
 * Targets:
 * - trigger: The element that triggers the tooltip (hover/focus/tap)
 * - tooltip: The tooltip content container (positioned absolutely)
 * - arrow: The tooltip arrow element (optional, for visual pointer)
 *
 * Values:
 * - delay (Number, default: 200): Delay in milliseconds before showing tooltip on hover
 * - position (String, default: "top"): Tooltip position (top/bottom/left/right)
 *
 * Events Dispatched:
 * - tooltip:shown: Fired when tooltip becomes visible (bubbles: true)
 * - tooltip:hidden: Fired when tooltip is hidden (bubbles: true)
 *
 * Accessibility Features:
 * - Uses aria-describedby to link trigger to tooltip content
 * - Sets aria-hidden on tooltip based on visibility state
 * - Supports ESC key to close tooltip
 * - Keyboard focus events trigger tooltip display
 * - Touch support for mobile devices (tap to show/hide)
 *
 * @example Basic usage
 *   <div data-controller="components--tooltip">
 *     <button data-components--tooltip-target="trigger">Hover me</button>
 *     <div data-components--tooltip-target="tooltip" role="tooltip">
 *       Tooltip content
 *     </div>
 *   </div>
 *
 * @example With custom delay
 *   <div data-controller="components--tooltip"
 *        data-components--tooltip-delay-value="500">
 *     <button data-components--tooltip-target="trigger">Patient hover</button>
 *     <div data-components--tooltip-target="tooltip" role="tooltip">
 *       I appear after 500ms
 *     </div>
 *   </div>
 *
 * @example With arrow
 *   <div data-controller="components--tooltip"
 *        data-components--tooltip-position-value="bottom">
 *     <button data-components--tooltip-target="trigger">Hover me</button>
 *     <div data-components--tooltip-target="tooltip" role="tooltip">
 *       Bottom tooltip
 *       <div data-components--tooltip-target="arrow"></div>
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["trigger", "tooltip", "arrow"]
  static values = {
    delay: { type: Number, default: 200 },
    position: { type: String, default: "top" }
  }

  connect() {
    this.showTimeout = null
    this.hideTimeout = null
    this.isVisible = false
    this.abortController = new AbortController()

    this.bindEvents()
  }

  disconnect() {
    this.abortController.abort()
    this.clearTimeouts()
  }

  bindEvents() {
    const signal = this.abortController.signal

    if (this.hasTriggerTarget) {
      // Mouse events
      this.triggerTarget.addEventListener("mouseenter", () => this.scheduleShow(), { signal })
      this.triggerTarget.addEventListener("mouseleave", () => this.scheduleHide(), { signal })

      // Focus events (for keyboard accessibility)
      this.triggerTarget.addEventListener("focusin", () => this.show(), { signal })
      this.triggerTarget.addEventListener("focusout", () => this.hide(), { signal })

      // Touch events (show on tap, hide on tap elsewhere)
      this.triggerTarget.addEventListener("touchstart", (e) => this.handleTouch(e), { signal })
    }

    // Hide on Escape key
    document.addEventListener("keydown", (e) => this.handleKeydown(e), { signal })
  }

  scheduleShow() {
    this.clearTimeouts()
    this.showTimeout = setTimeout(() => {
      this.show()
    }, this.delayValue)
  }

  scheduleHide() {
    this.clearTimeouts()
    this.hideTimeout = setTimeout(() => {
      this.hide()
    }, 100) // Small delay to prevent flickering
  }

  show() {
    if (this.isVisible || !this.hasTooltipTarget) return

    this.clearTimeouts()
    this.isVisible = true

    this.tooltipTarget.classList.remove("opacity-0", "invisible")
    this.tooltipTarget.classList.add("opacity-100", "visible")
    this.tooltipTarget.setAttribute("aria-hidden", "false")

    this.dispatch("shown")
  }

  hide() {
    if (!this.isVisible || !this.hasTooltipTarget) return

    this.clearTimeouts()
    this.isVisible = false

    this.tooltipTarget.classList.remove("opacity-100", "visible")
    this.tooltipTarget.classList.add("opacity-0", "invisible")
    this.tooltipTarget.setAttribute("aria-hidden", "true")

    this.dispatch("hidden")
  }

  handleTouch(event) {
    if (this.isVisible) {
      // Tooltip already visible - prevent default and hide it
      event.preventDefault()
      this.hide()
    } else {
      // Tooltip not visible - show it without preventing default
      // This allows scrolling to continue normally
      this.show()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isVisible) {
      this.hide()
    }
  }

  clearTimeouts() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout)
      this.showTimeout = null
    }
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
  }
}
