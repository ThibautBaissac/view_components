import { Controller } from "@hotwired/stimulus"

/**
 * Sidebar Controller
 *
 * Manages responsive sidebar behavior with mobile hamburger menu.
 * Handles opening/closing, overlay clicks, and keyboard navigation.
 *
 * Targets:
 * - sidebar: The main sidebar container
 * - panel: The mobile slide-in panel
 * - overlay: The mobile backdrop overlay
 * - hamburger: The mobile hamburger button
 *
 * Values:
 * - open: Whether the sidebar is currently open on mobile (default: false)
 *
 * Actions:
 * - toggle: Toggle sidebar open/closed
 * - open: Open the sidebar
 * - close: Close the sidebar
 *
 * Events:
 * - sidebar:open - Dispatched when sidebar opens
 * - sidebar:close - Dispatched when sidebar closes
 *
 * @example
 * <aside data-controller="components--sidebar"
 *        data-components--sidebar-open-value="false">
 *   <div data-components--sidebar-target="panel">...</div>
 *   <div data-components--sidebar-target="overlay"
 *        data-action="click->components--sidebar#close">...</div>
 * </aside>
 */
export default class extends Controller {
  static targets = ["sidebar", "panel", "overlay", "hamburger"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    // Bind keyboard event handler
    this.boundHandleKeydown = this.handleKeydown.bind(this)

    // Close sidebar on window resize to desktop
    this.boundHandleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.boundHandleResize)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("keydown", this.boundHandleKeydown)
    window.removeEventListener("resize", this.boundHandleResize)
  }

  /**
   * Toggle sidebar open/closed
   * @param {Event} event
   */
  toggle(event) {
    event?.preventDefault()
    event?.stopPropagation()

    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  /**
   * Open the sidebar (mobile only)
   */
  open() {
    this.openValue = true

    // Show overlay with fade-in
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
      // Force reflow for animation
      this.overlayTarget.offsetHeight
      this.overlayTarget.style.opacity = "1"
    }

    // Slide in panel
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("-translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    }

    // Prevent body scroll on mobile
    document.body.style.overflow = "hidden"

    // Add keyboard listener for ESC key
    document.addEventListener("keydown", this.boundHandleKeydown)

    // Dispatch custom event
    this.dispatch("open", { detail: { sidebar: this.element } })
  }

  /**
   * Close the sidebar
   */
  close() {
    this.openValue = false

    // Fade out overlay
    if (this.hasOverlayTarget) {
      this.overlayTarget.style.opacity = "0"
      setTimeout(() => {
        this.overlayTarget.classList.add("hidden")
      }, 300) // Match transition duration
    }

    // Slide out panel
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("translate-x-0")
      this.panelTarget.classList.add("-translate-x-full")
    }

    // Restore body scroll
    document.body.style.overflow = ""

    // Remove keyboard listener
    document.removeEventListener("keydown", this.boundHandleKeydown)

    // Dispatch custom event
    this.dispatch("close", { detail: { sidebar: this.element } })
  }

  /**
   * Handle keyboard events (ESC to close)
   * @param {KeyboardEvent} event
   */
  handleKeydown(event) {
    if (event.key === "Escape" && this.openValue) {
      event.preventDefault()
      this.close()
    }
  }

  /**
   * Handle window resize - close sidebar when resizing to desktop
   */
  handleResize() {
    // Close mobile sidebar when viewport becomes desktop-sized
    if (window.innerWidth >= 1024 && this.openValue) {
      this.close()
    }
  }

  /**
   * Value changed callback for open state
   */
  openValueChanged() {
    // Update aria-expanded on hamburger button
    if (this.hasHamburgerTarget) {
      this.hamburgerTarget.setAttribute("aria-expanded", this.openValue.toString())
    }

    // Update panel aria-hidden
    if (this.hasPanelTarget) {
      this.panelTarget.setAttribute("aria-hidden", (!this.openValue).toString())
    }
  }
}
