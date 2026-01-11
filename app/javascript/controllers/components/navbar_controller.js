import { Controller } from "@hotwired/stimulus"

/**
 * Navbar Controller
 *
 * Handles mobile menu toggle for responsive navigation.
 *
 * @example
 *   <nav data-controller="components--navbar">
 *     <button data-action="click->components--navbar#toggleMenu">Menu</button>
 *     <div data-components--navbar-target="menu">...</div>
 *   </nav>
 */
export default class extends Controller {
  static targets = ["menu", "menuButton", "menuIcon", "closeIcon"]

  connect() {
    // Store original trigger for focus return
    this.previouslyFocusedElement = null

    // Bind event handlers
    this.handleEscKey = this.handleEscKey.bind(this)
    this.handleFocusTrap = this.handleFocusTrap.bind(this)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("keydown", this.handleEscKey)
    this.menuTarget.removeEventListener("keydown", this.handleFocusTrap)
  }

  /**
   * Toggle mobile menu visibility
   * @public
   */
  toggleMenu() {
    const isOpen = !this.menuTarget.classList.contains("hidden")

    if (isOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  /**
   * Open mobile menu
   * @public
   */
  openMenu() {
    // Store previously focused element for focus management
    this.previouslyFocusedElement = document.activeElement

    this.menuTarget.classList.remove("hidden")
    this.menuTarget.setAttribute("aria-hidden", "false")
    this.menuIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
    this.menuButtonTarget.setAttribute("aria-expanded", "true")

    // Add event listeners
    document.addEventListener("keydown", this.handleEscKey)
    this.menuTarget.addEventListener("keydown", this.handleFocusTrap)

    // Focus first focusable element in menu
    this.focusFirstMenuElement()
  }

  /**
   * Close mobile menu
   * @public
   */
  closeMenu() {
    this.menuTarget.classList.add("hidden")
    this.menuTarget.setAttribute("aria-hidden", "true")
    this.menuIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
    this.menuButtonTarget.setAttribute("aria-expanded", "false")

    // Remove event listeners
    document.removeEventListener("keydown", this.handleEscKey)
    this.menuTarget.removeEventListener("keydown", this.handleFocusTrap)

    // Return focus to previously focused element (usually the menu button)
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    } else {
      this.menuButtonTarget.focus()
    }
  }

  /**
   * Handle ESC key press to close menu
   * @private
   */
  handleEscKey(event) {
    if (event.key === "Escape" || event.key === "Esc") {
      event.preventDefault()
      this.closeMenu()
    }
  }

  /**
   * Trap focus within mobile menu (prevents tabbing out)
   * @private
   */
  handleFocusTrap(event) {
    if (event.key !== "Tab") return

    const focusableElements = this.getFocusableElements()
    if (focusableElements.length === 0) return

    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    // If shift+tab on first element, move to last element
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus()
    }
    // If tab on last element, move to first element
    else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus()
    }
  }

  /**
   * Focus first focusable element in mobile menu
   * @private
   */
  focusFirstMenuElement() {
    const focusableElements = this.getFocusableElements()

    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }

  /**
   * Get all focusable elements in menu
   * @private
   * @returns {NodeList} Focusable elements
   */
  getFocusableElements() {
    return this.menuTarget.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
    )
  }

  /**
   * Handle window resize - close menu on desktop breakpoint
   * @public
   */
  handleResize() {
    if (window.innerWidth >= 768) { // md breakpoint
      this.closeMenu()
    }
  }
}
