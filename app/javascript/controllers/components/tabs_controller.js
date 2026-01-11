import { Controller } from "@hotwired/stimulus"

/**
 * Tabs Controller
 *
 * Manages accessible tabbed interface behavior including:
 * - Tab selection and panel visibility
 * - Keyboard navigation (arrow keys, Home, End)
 * - ARIA attributes management
 * - Focus management
 *
 * Targets:
 * - tab: Tab button elements
 * - panel: Tab panel elements
 *
 * Values:
 * - initialIndex: Index of the initially selected tab (default: 0)
 * - selectedClass: CSS classes for the selected tab button
 *
 * Actions:
 * - select: Selects a tab when clicked
 * - handleKeydown: Handles keyboard navigation
 *
 * Events:
 * - tabs:change - Dispatched when tab selection changes
 *
 * @example
 * <div data-controller="components--tabs"
 *      data-components--tabs-initial-index-value="0">
 *   <div role="tablist">
 *     <button role="tab" data-components--tabs-target="tab" data-index="0">Tab 1</button>
 *     <button role="tab" data-components--tabs-target="tab" data-index="1">Tab 2</button>
 *   </div>
 *   <div role="tabpanel" data-components--tabs-target="panel" data-index="0">Panel 1</div>
 *   <div role="tabpanel" data-components--tabs-target="panel" data-index="1">Panel 2</div>
 * </div>
 */
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    initialIndex: { type: Number, default: 0 }
  }

  connect() {
    // Set initial tab selection
    this.currentIndex = this.initialIndexValue

    // Store initial classes from each tab for toggling
    this.extractTabClasses()

    // Ensure proper state on connect
    this.updateTabStates()
  }

  /**
   * Extracts the initial selected/unselected classes from the rendered tabs.
   * This allows us to toggle between states dynamically by storing reference
   * classes for each state and applying them during tab selection.
   *
   * @private
   */
  extractTabClasses() {
    this.selectedClasses = new Map()
    this.unselectedClasses = new Map()

    // Find reference tabs for selected and unselected states
    const selectedTab = this.tabTargets.find(t => t.getAttribute('aria-selected') === 'true')
    const unselectedTab = this.tabTargets.find(t => t.getAttribute('aria-selected') === 'false')

    // Store reference classes
    const selectedRefClasses = selectedTab ? Array.from(selectedTab.classList) : []
    const unselectedRefClasses = unselectedTab ? Array.from(unselectedTab.classList) : []

    // Apply reference classes to all tabs
    this.tabTargets.forEach((tab, index) => {
      const isSelected = tab.getAttribute('aria-selected') === 'true'

      if (isSelected) {
        this.selectedClasses.set(index, Array.from(tab.classList))
        this.unselectedClasses.set(index, unselectedRefClasses)
      } else {
        this.unselectedClasses.set(index, Array.from(tab.classList))
        this.selectedClasses.set(index, selectedRefClasses)
      }
    })
  }

  /**
   * Selects a tab when clicked
   * @param {Event} event - Click event from tab button
   */
  select(event) {
    const tab = event.currentTarget
    const index = parseInt(tab.dataset.index, 10)

    if (tab.disabled) {
      return
    }

    this.selectTab(index)
  }

  /**
   * Handles keyboard navigation within the tablist
   * Implements WAI-ARIA keyboard patterns for tabs
   * @param {KeyboardEvent} event - Keydown event
   */
  handleKeydown(event) {
    const isVertical = this.element.querySelector('[role="tablist"]')?.getAttribute('aria-orientation') === 'vertical'

    // Determine which keys to use based on orientation
    const prevKey = isVertical ? 'ArrowUp' : 'ArrowLeft'
    const nextKey = isVertical ? 'ArrowDown' : 'ArrowRight'

    switch (event.key) {
      case prevKey:
        event.preventDefault()
        this.selectPreviousTab()
        break
      case nextKey:
        event.preventDefault()
        this.selectNextTab()
        break
      case 'Home':
        event.preventDefault()
        this.selectFirstTab()
        break
      case 'End':
        event.preventDefault()
        this.selectLastTab()
        break
    }
  }

  /**
   * Selects a tab by index
   * @param {number} index - Index of the tab to select
   */
  selectTab(index) {
    if (index < 0 || index >= this.tabTargets.length) {
      return
    }

    const targetTab = this.tabTargets[index]
    if (targetTab.disabled) {
      return
    }

    const previousIndex = this.currentIndex
    this.currentIndex = index

    this.updateTabStates()

    // Focus the newly selected tab
    this.tabTargets[index].focus()

    // Dispatch change event
    this.dispatch("change", {
      detail: {
        previousIndex,
        currentIndex: index,
        tabId: this.tabTargets[index].id
      }
    })
  }

  /**
   * Selects the previous non-disabled tab (wraps around)
   */
  selectPreviousTab() {
    let index = this.currentIndex - 1

    // Wrap around to last tab if at the beginning
    if (index < 0) {
      index = this.tabTargets.length - 1
    }

    // Skip disabled tabs
    let attempts = 0
    while (this.tabTargets[index].disabled && attempts < this.tabTargets.length) {
      index = index - 1 < 0 ? this.tabTargets.length - 1 : index - 1
      attempts++
    }

    this.selectTab(index)
  }

  /**
   * Selects the next non-disabled tab (wraps around)
   */
  selectNextTab() {
    let index = this.currentIndex + 1

    // Wrap around to first tab if at the end
    if (index >= this.tabTargets.length) {
      index = 0
    }

    // Skip disabled tabs
    let attempts = 0
    while (this.tabTargets[index].disabled && attempts < this.tabTargets.length) {
      index = (index + 1) % this.tabTargets.length
      attempts++
    }

    this.selectTab(index)
  }

  /**
   * Selects the first non-disabled tab
   */
  selectFirstTab() {
    for (let i = 0; i < this.tabTargets.length; i++) {
      if (!this.tabTargets[i].disabled) {
        this.selectTab(i)
        return
      }
    }
  }

  /**
   * Selects the last non-disabled tab
   */
  selectLastTab() {
    for (let i = this.tabTargets.length - 1; i >= 0; i--) {
      if (!this.tabTargets[i].disabled) {
        this.selectTab(i)
        return
      }
    }
  }

  /**
   * Updates all tab and panel states based on current selection
   */
  updateTabStates() {
    this.tabTargets.forEach((tab, index) => {
      const isSelected = index === this.currentIndex
      const panel = this.panelTargets[index]

      // Update tab button ARIA attributes
      tab.setAttribute('aria-selected', isSelected)
      tab.setAttribute('tabindex', isSelected ? '0' : '-1')

      // Update tab button CSS classes
      this.updateTabClasses(tab, index, isSelected)

      // Update panel visibility
      if (panel) {
        if (isSelected) {
          panel.hidden = false
          panel.classList.remove('hidden')
        } else {
          panel.hidden = true
          panel.classList.add('hidden')
        }
      }
    })
  }

  /**
   * Updates the CSS classes of a tab button based on selection state.
   * Removes classes from the previous state and applies classes for the new state.
   *
   * @private
   * @param {HTMLElement} tab - The tab button element
   * @param {number} index - The tab index
   * @param {boolean} isSelected - Whether the tab is selected
   */
  updateTabClasses(tab, index, isSelected) {
    if (isSelected) {
      // Remove unselected classes and add selected classes
      const unselectedClasses = this.unselectedClasses.get(index) || []
      const selectedClasses = this.selectedClasses.get(index) || this.selectedClasses.get(0) || []

      // Remove all unselected classes
      unselectedClasses.forEach(cls => {
        if (!selectedClasses.includes(cls)) {
          tab.classList.remove(cls)
        }
      })

      // Add all selected classes
      selectedClasses.forEach(cls => tab.classList.add(cls))
    } else {
      // Remove selected classes and add unselected classes
      const selectedClasses = this.selectedClasses.get(index) || this.selectedClasses.get(0) || []
      const unselectedClasses = this.unselectedClasses.get(index) || []

      // Remove all selected classes
      selectedClasses.forEach(cls => {
        if (!unselectedClasses.includes(cls)) {
          tab.classList.remove(cls)
        }
      })

      // Add all unselected classes
      unselectedClasses.forEach(cls => tab.classList.add(cls))
    }
  }
}
