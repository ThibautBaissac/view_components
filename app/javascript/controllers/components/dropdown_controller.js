import { Controller } from "@hotwired/stimulus"

/**
 * Dropdown Controller
 *
 * Handles dropdown menu interactions with keyboard navigation and accessibility.
 *
 * Targets:
 * - trigger: The button that opens/closes the dropdown
 * - menu: The dropdown menu container
 * - item: Individual menu items (for keyboard navigation)
 * - announcement: Screen reader announcement element (for state changes)
 *
 * Values:
 * - open: Whether the dropdown is currently open (default: false)
 * - closeOnSelect: Whether to close dropdown when an item is selected (default: true)
 * - placement: Position of dropdown relative to trigger (default: "bottom-start")
 */
export default class extends Controller {
  static targets = ["trigger", "menu", "item", "announcement"]
  static values = {
    open: { type: Boolean, default: false },
    closeOnSelect: { type: Boolean, default: true },
    placement: { type: String, default: "bottom-start" },
    openedMessage: { type: String, default: "Menu opened" },
    closedMessage: { type: String, default: "Menu closed" }
  }

  connect() {
    this.focusedIndex = -1
    this.abortController = null
  }

  disconnect() {
    if (this.abortController) {
      this.abortController.abort()
    }
  }

  toggle(event) {
    event?.preventDefault()
    event?.stopPropagation()

    if (this.openValue) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.openValue = true
    this.menuTarget.classList.remove("hidden")
    this.menuTarget.classList.add("animate-fade-in")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.focusedIndex = -1

    // Announce state change for screen readers
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = this.openedMessageValue
    }

    // Create new AbortController for this open session
    this.abortController = new AbortController()
    const signal = this.abortController.signal

    // Add event listeners with AbortController signal
    document.addEventListener("click", (e) => this.handleClickOutside(e), { signal })
    document.addEventListener("keydown", (e) => this.handleKeydown(e), { signal })

    // Dispatch custom event
    this.dispatch("opened")
  }

  close() {
    this.openValue = false
    this.menuTarget.classList.add("hidden")
    this.menuTarget.classList.remove("animate-fade-in")
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.focusedIndex = -1

    // Announce state change for screen readers
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = this.closedMessageValue
    }

    // Abort all event listeners from this open session
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }

    // Return focus to trigger
    this.triggerTarget.focus()

    // Dispatch custom event
    this.dispatch("closed")
  }

  select(event) {
    // Dispatch select event with item data
    this.dispatch("select", { detail: { item: event.currentTarget } })

    if (this.closeOnSelectValue) {
      this.close()
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleKeydown(event) {
    const items = this.itemTargets.filter(
      item => !item.hasAttribute("disabled") && !item.dataset.divider
    )

    switch (event.key) {
      case "Escape":
        event.preventDefault()
        this.close()
        break

      case "ArrowDown":
        event.preventDefault()
        this.focusNextItem(items)
        break

      case "ArrowUp":
        event.preventDefault()
        this.focusPreviousItem(items)
        break

      case "Home":
        event.preventDefault()
        this.focusFirstItem(items)
        break

      case "End":
        event.preventDefault()
        this.focusLastItem(items)
        break

      case "Tab":
        // Allow tab to close the menu and move focus naturally
        this.close()
        break

      case "Enter":
      case " ":
        if (this.focusedIndex >= 0 && items[this.focusedIndex]) {
          event.preventDefault()
          items[this.focusedIndex].click()
        }
        break
    }
  }

  focusNextItem(items) {
    if (items.length === 0) return

    this.focusedIndex = (this.focusedIndex + 1) % items.length
    this.focusItem(items[this.focusedIndex])
  }

  focusPreviousItem(items) {
    if (items.length === 0) return

    this.focusedIndex = this.focusedIndex <= 0 ? items.length - 1 : this.focusedIndex - 1
    this.focusItem(items[this.focusedIndex])
  }

  focusFirstItem(items) {
    if (items.length === 0) return

    this.focusedIndex = 0
    this.focusItem(items[0])
  }

  focusLastItem(items) {
    if (items.length === 0) return

    this.focusedIndex = items.length - 1
    this.focusItem(items[this.focusedIndex])
  }

  focusItem(item) {
    // Remove focus styling from all items
    this.itemTargets.forEach(i => {
      i.classList.remove("bg-slate-100", "text-slate-900", "outline-none")
    })

    // Add focus styling to current item
    item.classList.add("bg-slate-100", "text-slate-900", "outline-none")
    item.focus()
  }

  // Value changed callback
  openValueChanged(value) {
    if (value) {
      this.menuTarget?.classList.remove("hidden")
      this.triggerTarget?.setAttribute("aria-expanded", "true")
    } else {
      this.menuTarget?.classList.add("hidden")
      this.triggerTarget?.setAttribute("aria-expanded", "false")
    }
  }
}
