import { Controller } from "@hotwired/stimulus"

/**
 * MultiSelect Controller
 *
 * Handles multi-select with tag/chip interface for better UX than native <select multiple>.
 *
 * Targets:
 * - input: The search/filter input field
 * - dropdown: The dropdown menu with options
 * - option: Individual option elements (clickable)
 * - tags: Container for selected tags
 * - tag: Individual tag elements (with remove button)
 * - hidden: Hidden input fields for form submission
 *
 * Values:
 * - selected: Array of currently selected values
 * - open: Whether the dropdown is currently open
 * - placeholder: Placeholder text for the input
 */
export default class extends Controller {
  static targets = ["trigger", "input", "dropdown", "option", "tags", "tag", "hidden", "placeholder", "error"]
  static values = {
    selected: { type: Array, default: [] },
    open: { type: Boolean, default: false },
    placeholder: { type: String, default: "Search..." },
    highlightedIndex: { type: Number, default: -1 }
  }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.highlightedIndexValue = -1
    // Store original error message for restoration
    this.originalErrorMessage = this.hasErrorTarget ? this.errorTarget.textContent : null
    this.hasOriginalError = this.hasErrorTarget
    this.updateUI()
  }

  disconnect() {
    this.removeEventListeners()
  }

  // Toggle dropdown open/close
  toggleDropdown(event) {
    event?.preventDefault()
    event?.stopPropagation()

    if (this.openValue) {
      this.closeDropdown()
    } else {
      this.openDropdown()
    }
  }

  // Open dropdown
  openDropdown(event) {
    event?.preventDefault()
    event?.stopPropagation()

    if (this.openValue) return

    this.openValue = true
    this.dropdownTarget.classList.remove("hidden")
    this.dropdownTarget.classList.add("animate-fade-in")
    this.filterOptions()
    this.addEventListener()

    // Update ARIA and focus search input
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }
    if (this.hasInputTarget) {
      // Small delay to ensure dropdown is visible
      setTimeout(() => this.inputTarget.focus(), 10)
    }
  }

  // Close dropdown
  closeDropdown() {
    if (!this.openValue) return

    this.openValue = false
    this.dropdownTarget.classList.add("hidden")

    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }

    this.filterOptions() // Reset filter
    this.removeEventListeners()
  }

  // Handle click outside to close dropdown
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeDropdown()
    }
  }

  // Filter options based on search input
  filterOptions(event) {
    const query = this.hasInputTarget ? this.inputTarget.value.toLowerCase() : ""

    this.optionTargets.forEach((option) => {
      const text = option.textContent.toLowerCase()
      const matches = text.includes(query)

      if (matches) {
        option.classList.remove("hidden")
      } else {
        option.classList.add("hidden")
      }
    })

    // Reset keyboard navigation highlight when filtering
    this.resetHighlight()

    // Show "no results" message if all options are hidden
    this.updateNoResultsMessage()
  }

  // Select an option (add tag)
  selectOption(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const label = option.dataset.label || option.textContent.trim()

    if (this.selectedValue.includes(value)) {
      // Already selected, deselect it and remove the tag from DOM
      this.deselectValue(value)
      this.removeTagElement(value)
    } else {
      // Add to selected
      this.selectedValue = [...this.selectedValue, value]
      this.addTag(value, label)
      this.updateHiddenInputs()
      this.updateOptionStates()
      this.updatePlaceholder()
      this.clearError()
    }

    // Clear search and keep dropdown open for more selections
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
    this.filterOptions()
  }

  // Remove a tag (deselect)
  removeTag(event) {
    const tag = event.currentTarget.closest("[data-components--multi-select-target='tag']")
    const value = tag.dataset.value

    this.deselectValue(value)
    tag.remove()
  }

  // Remove a tag element by value
  removeTagElement(value) {
    const tag = this.tagTargets.find((t) => t.dataset.value === value)
    if (tag) {
      tag.remove()
    }
  }

  // Deselect a value
  deselectValue(value) {
    this.selectedValue = this.selectedValue.filter((v) => v !== value)
    this.updateHiddenInputs()
    this.updateOptionStates()
    this.updatePlaceholder()

    // Restore error state if no selections remain and there was an original error
    if (this.selectedValue.length === 0 && this.hasOriginalError) {
      this.restoreError()
    }
  }

  // Add a tag element
  addTag(value, label) {
    const tag = document.createElement("span")
    tag.setAttribute("data-components--multi-select-target", "tag")
    tag.dataset.value = value
    tag.className = "inline-flex items-center gap-1 px-2 py-0.5 text-xs font-medium text-blue-700 bg-blue-50 rounded border border-blue-200"
    tag.innerHTML = `
      <span>${this.escapeHtml(label)}</span>
      <button
        type="button"
        data-action="click->components--multi-select#removeTag:stop"
        class="flex items-center justify-center w-3.5 h-3.5 rounded-full hover:bg-blue-200 focus:outline-none focus:ring-1 focus:ring-blue-500"
        aria-label="Remove ${this.escapeHtml(label)}"
      >
        <svg class="w-2.5 h-2.5" viewBox="0 0 20 20" fill="currentColor">
          <path d="M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z" />
        </svg>
      </button>
    `

    this.tagsTarget.appendChild(tag)
  }

  // Update hidden input fields for form submission
  updateHiddenInputs() {
    // Remove existing hidden inputs
    this.hiddenTargets.forEach((input) => input.remove())

    // Add new hidden inputs for each selected value
    this.selectedValue.forEach((value) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.element.dataset.name
      input.value = value
      input.setAttribute("data-components--multi-select-target", "hidden")
      this.element.appendChild(input)
    })
  }

  // Update option visual states (checked/unchecked)
  updateOptionStates() {
    this.optionTargets.forEach((option) => {
      const value = option.dataset.value
      const isSelected = this.selectedValue.includes(value)
      const checkbox = option.querySelector("[data-checkbox]")

      if (isSelected) {
        option.classList.add("bg-blue-50")
        option.setAttribute("aria-selected", "true")
        if (checkbox) {
          checkbox.innerHTML = this.getCheckedIcon()
        }
      } else {
        option.classList.remove("bg-blue-50")
        option.setAttribute("aria-selected", "false")
        if (checkbox) {
          checkbox.innerHTML = this.getUncheckedIcon()
        }
      }
    })
  }

  // Update UI based on selected values
  updateUI() {
    this.updateOptionStates()
    this.updatePlaceholder()
  }

  // Update trigger button placeholder text visibility
  updatePlaceholder() {
    if (this.hasPlaceholderTarget) {
      if (this.selectedValue.length > 0) {
        this.placeholderTarget.classList.add("hidden")
      } else {
        this.placeholderTarget.classList.remove("hidden")
      }
    }
  }

  // Clear error state when user makes a valid selection
  clearError() {
    // Only clear if there are selections
    if (this.selectedValue.length === 0) return

    // Hide error message (don't remove, so we can restore it)
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }

    // Remove error styling from trigger
    if (this.hasTriggerTarget) {
      this.triggerTarget.classList.remove(
        "border-red-300",
        "hover:border-red-400",
        "focus:border-red-500",
        "focus:ring-red-500"
      )
      // Add normal styling
      this.triggerTarget.classList.add(
        "border-gray-300",
        "hover:border-gray-400",
        "focus:border-blue-500",
        "focus:ring-blue-500"
      )
    }

    // Remove aria-invalid attribute
    this.element.removeAttribute("aria-invalid")
  }

  // Restore error state when all selections are removed
  restoreError() {
    // Show error message
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("hidden")
    }

    // Add error styling to trigger
    if (this.hasTriggerTarget) {
      this.triggerTarget.classList.remove(
        "border-gray-300",
        "hover:border-gray-400",
        "focus:border-blue-500",
        "focus:ring-blue-500"
      )
      this.triggerTarget.classList.add(
        "border-red-300",
        "hover:border-red-400",
        "focus:border-red-500",
        "focus:ring-red-500"
      )
    }

    // Restore aria-invalid attribute
    this.element.setAttribute("aria-invalid", "true")
  }

  // Show/hide "no results" message
  updateNoResultsMessage() {
    const visibleOptions = this.optionTargets.filter((opt) => !opt.classList.contains("hidden"))
    const noResultsEl = this.element.querySelector("[data-no-results]")

    if (noResultsEl) {
      if (visibleOptions.length === 0) {
        noResultsEl.classList.remove("hidden")
      } else {
        noResultsEl.classList.add("hidden")
      }
    }
  }

  // Add event listeners
  addEventListener() {
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  // Remove event listeners
  removeEventListeners() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  // Escape HTML to prevent XSS
  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  // Get checked icon SVG
  getCheckedIcon() {
    return `
      <svg class="w-5 h-5 text-blue-600" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm3.857-9.809a.75.75 0 0 0-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 1 0-1.06 1.061l2.5 2.5a.75.75 0 0 0 1.137-.089l4-5.5Z" clip-rule="evenodd" />
      </svg>
    `
  }

  // Get unchecked icon SVG
  getUncheckedIcon() {
    return `
      <svg class="w-5 h-5 text-gray-300" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm0-2a6 6 0 1 0 0-12 6 6 0 0 0 0 12Z" clip-rule="evenodd" />
      </svg>
    `
  }

  // Handle keyboard navigation
  handleKeydown(event) {
    const visibleOptions = this.getVisibleOptions()

    switch (event.key) {
      case "Escape":
        event.preventDefault()
        this.closeDropdown()
        break
      case "ArrowDown":
        event.preventDefault()
        this.highlightNext(visibleOptions)
        break
      case "ArrowUp":
        event.preventDefault()
        this.highlightPrevious(visibleOptions)
        break
      case "Enter":
        event.preventDefault()
        if (this.highlightedIndexValue >= 0 && visibleOptions[this.highlightedIndexValue]) {
          this.selectHighlightedOption(visibleOptions[this.highlightedIndexValue])
        }
        break
      case "Backspace":
        // Remove last tag if input is empty
        if (this.inputTarget.value === "" && this.selectedValue.length > 0) {
          event.preventDefault()
          const lastTag = this.tagTargets[this.tagTargets.length - 1]
          if (lastTag) {
            const value = lastTag.dataset.value
            this.deselectValue(value)
            lastTag.remove()
          }
        }
        break
    }
  }

  // Get visible (not hidden) options
  getVisibleOptions() {
    return this.optionTargets.filter((opt) => !opt.classList.contains("hidden"))
  }

  // Highlight next option in list
  highlightNext(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.highlightedIndexValue = Math.min(
      this.highlightedIndexValue + 1,
      visibleOptions.length - 1
    )
    this.updateHighlight(visibleOptions)
  }

  // Highlight previous option in list
  highlightPrevious(visibleOptions) {
    if (visibleOptions.length === 0) return

    this.highlightedIndexValue = Math.max(this.highlightedIndexValue - 1, 0)
    this.updateHighlight(visibleOptions)
  }

  // Update visual highlight on options
  updateHighlight(visibleOptions) {
    // Remove highlight from all options
    this.optionTargets.forEach((opt) => {
      opt.classList.remove("bg-blue-100", "ring-2", "ring-blue-500", "ring-inset")
    })

    // Add highlight to current option
    const highlightedOption = visibleOptions[this.highlightedIndexValue]
    if (highlightedOption) {
      highlightedOption.classList.add("bg-blue-100", "ring-2", "ring-blue-500", "ring-inset")
      highlightedOption.scrollIntoView({ block: "nearest" })

      // Set aria-activedescendant for screen reader support
      if (this.hasTriggerTarget && highlightedOption.id) {
        this.triggerTarget.setAttribute('aria-activedescendant', highlightedOption.id)
      }
    } else {
      // Clear aria-activedescendant when no option is highlighted
      if (this.hasTriggerTarget) {
        this.triggerTarget.removeAttribute('aria-activedescendant')
      }
    }
  }

  // Select the currently highlighted option
  selectHighlightedOption(option) {
    const value = option.dataset.value
    const label = option.dataset.label || option.textContent.trim()

    if (this.selectedValue.includes(value)) {
      this.deselectValue(value)
      this.removeTagElement(value)
    } else {
      this.selectedValue = [...this.selectedValue, value]
      this.addTag(value, label)
      this.updateHiddenInputs()
      this.updateOptionStates()
      this.updatePlaceholder()
      this.clearError()
    }

    // Clear search and reset highlight
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
    this.filterOptions()
    this.highlightedIndexValue = -1
    this.updateHighlight(this.getVisibleOptions())
  }

  // Reset highlight when filtering
  resetHighlight() {
    this.highlightedIndexValue = -1
    this.optionTargets.forEach((opt) => {
      opt.classList.remove("bg-blue-100", "ring-2", "ring-blue-500", "ring-inset")
    })
  }

  // Handle keyboard events on trigger for accessibility
  handleTriggerKeydown(event) {
    switch (event.key) {
      case "Enter":
      case " ":
        event.preventDefault()
        this.toggleDropdown(event)
        break
      case "ArrowDown":
        event.preventDefault()
        this.openDropdown(event)
        break
      case "Escape":
        if (this.openValue) {
          event.preventDefault()
          this.closeDropdown()
        }
        break
    }
  }
}
