import { Controller } from "@hotwired/stimulus"

/**
 * Modal Controller
 *
 * Manages modal dialog behavior including opening, closing, keyboard navigation,
 * backdrop clicks, and focus trapping. Uses the native HTML <dialog> element
 * for better accessibility.
 *
 * Targets:
 * - panel: The modal panel container (for click-outside detection)
 *
 * Values:
 * - open: Whether the modal is currently open (default: false)
 * - dismissible: Whether the modal can be dismissed (default: true)
 * - closeOnSubmit: Whether to close after successful form submission (default: true)
 *
 * Actions:
 * - open: Opens the modal
 * - close: Closes the modal
 * - backdropClick: Handles clicks on the backdrop
 *
 * Events:
 * - modal:open - Dispatched when modal opens
 * - modal:close - Dispatched when modal closes
 * - modal:cancel - Dispatched when modal is cancelled (ESC or backdrop)
 *
 * @example
 * <dialog data-controller="components--modal"
 *         data-components--modal-dismissible-value="true">
 *   <div data-components--modal-target="panel">
 *     <button data-action="click->components--modal#close">Close</button>
 *   </div>
 * </dialog>
 *
 * <!-- Trigger button outside the modal -->
 * <button data-action="click->components--modal#open"
 *         data-components--modal-target-param="modal-id">
 *   Open Modal
 * </button>
 */
export default class extends Controller {
  static targets = ["panel"]
  static values = {
    open: { type: Boolean, default: false },
    dismissible: { type: Boolean, default: true },
    closeOnSubmit: { type: Boolean, default: true }
  }

  connect() {
    // Store reference to focusable elements for focus trapping
    this.previouslyFocusedElement = null
    this.mainContent = null
    this._updatingOpenValue = false

    // Bind event handlers
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleFormSubmit = this.handleFormSubmit.bind(this)
    this.handleTriggerOpen = this.handleTriggerOpen.bind(this)

    // Add event listeners
    this.element.addEventListener("keydown", this.handleKeydown)
    this.element.addEventListener("turbo:submit-end", this.handleFormSubmit)
    this.element.addEventListener("modal:trigger-open", this.handleTriggerOpen)

    // Open modal if open value is true on connect
    if (this.openValue) {
      this.open()
    }
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.handleKeydown)
    this.element.removeEventListener("turbo:submit-end", this.handleFormSubmit)
    this.element.removeEventListener("modal:trigger-open", this.handleTriggerOpen)

    // Remove inert attribute if modal was open
    if (this.mainContent) {
      this.mainContent.removeAttribute("inert")
      this.mainContent = null
    }

    // Restore focus if modal was open
    if (this.element.open && this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
    }
  }

  /**
   * Handles trigger-open event from external buttons
   * @param {CustomEvent} event - Trigger open event
   */
  handleTriggerOpen(event) {
    this.open()
  }

  /**   * Triggers opening of a modal from an external button
   * Finds modal by ID from data-modal-target and dispatches custom event
   * @param {Event} event - Click event from trigger button
   */
  triggerOpen(event) {
    event.preventDefault()
    const modalId = event.currentTarget.dataset.modalTarget
    if (!modalId) {
      console.error("Modal trigger missing data-modal-target attribute")
      return
    }

    const modal = document.getElementById(modalId)
    if (!modal) {
      console.error(`Modal not found with ID: ${modalId}`)
      return
    }

    modal.dispatchEvent(new CustomEvent("modal:trigger-open", { bubbles: false }))
  }

  /**   * Opens the modal
   * @param {Event} [event] - Optional event (for trigger buttons)
   */
  open(event) {
    // Support opening from external trigger with modal ID parameter
    if (event?.params?.target) {
      const targetModal = document.getElementById(event.params.target)
      if (targetModal && targetModal !== this.element) {
        // Dispatch to the correct modal controller
        targetModal.dispatchEvent(new CustomEvent("modal:trigger-open"))
        return
      }
    }

    if (this.element.tagName !== "DIALOG") return

    // Store currently focused element
    this.previouslyFocusedElement = document.activeElement

    // Find main content and mark as inert for accessibility
    this.mainContent = document.querySelector('main') || document.body
    this.mainContent.setAttribute('inert', '')

    // Open the dialog
    this.element.showModal()
    this.openValue = true

    // Focus first focusable element
    this.focusFirstElement()

    // Dispatch open event
    this.dispatch("open", { detail: { modal: this.element } })
  }

  /**
   * Closes the modal
   * @param {Event} [event] - Optional event
   */
  close(event) {
    event?.preventDefault()

    if (this.element.tagName !== "DIALOG") return

    // Remove inert attribute from main content
    if (this.mainContent) {
      this.mainContent.removeAttribute('inert')
      this.mainContent = null
    }

    this.element.close()
    this.openValue = false

    // Restore focus to previously focused element
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }

    // Dispatch close event
    this.dispatch("close", { detail: { modal: this.element } })
  }

  /**
   * Handles clicks on the backdrop (outside the panel)
   * @param {Event} event - Click event
   */
  backdropClick(event) {
    if (!this.dismissibleValue) return

    // Only close if click was on the dialog backdrop, not the panel
    if (this.hasPanelTarget && !this.panelTarget.contains(event.target)) {
      this.cancel()
    }
  }

  /**
   * Cancels and closes the modal (for ESC key or backdrop clicks)
   */
  cancel() {
    if (!this.dismissibleValue) return

    this.dispatch("cancel", { detail: { modal: this.element } })
    this.close()
  }

  /**
   * Handles keydown events for accessibility
   * @param {KeyboardEvent} event - Keyboard event
   */
  handleKeydown(event) {
    if (this.element.tagName !== "DIALOG") return

    if (event.key === "Escape") {
      event.preventDefault()
      if (this.dismissibleValue) {
        this.cancel()
      }
    }

    // Focus trapping with Tab key
    if (event.key === "Tab") {
      this.trapFocus(event)
    }
  }

  /**
   * Handles form submission within the modal
   * @param {CustomEvent} event - Turbo submit-end event
   */
  handleFormSubmit(event) {
    if (!this.closeOnSubmitValue) return

    // Close modal on successful form submission
    if (event.detail?.success) {
      this.close()
    }
  }

  /**
   * Traps focus within the modal
   * @param {KeyboardEvent} event - Tab keydown event
   */
  trapFocus(event) {
    const focusableElements = this.getFocusableElements()
    if (focusableElements.length === 0) return

    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey) {
      // Shift + Tab: if on first element, go to last
      if (document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      }
    } else {
      // Tab: if on last element, go to first
      if (document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }

  /**
   * Gets all focusable elements within the modal
   * @returns {HTMLElement[]} Array of focusable elements
   */
  getFocusableElements() {
    const selector = [
      "button:not([disabled])",
      "input:not([disabled])",
      "select:not([disabled])",
      "textarea:not([disabled])",
      "a[href]",
      "[contenteditable]:not([contenteditable='false'])",
      "[tabindex]:not([tabindex='-1'])"
    ].join(", ")

    return Array.from(this.element.querySelectorAll(selector))
  }

  /**
   * Focuses the first focusable element in the modal
   */
  focusFirstElement() {
    requestAnimationFrame(() => {
      const focusableElements = this.getFocusableElements()

      // Try to focus the first non-close-button focusable element
      const firstFocusable = focusableElements.find(el => {
        return !el.hasAttribute("data-modal-close")
      }) || focusableElements[0]

      if (firstFocusable) {
        firstFocusable.focus()
      }
    })
  }

  /**
   * Value change callback for open state
   */
  openValueChanged(value, previousValue) {
    // Skip on initial connect when previousValue is undefined
    if (previousValue === undefined) return
    // Prevent recursive calls
    if (this._updatingOpenValue) return

    this._updatingOpenValue = true
    if (value && !this.element.open) {
      this.open()
    } else if (!value && this.element.open) {
      this.close()
    }
    this._updatingOpenValue = false
  }
}
