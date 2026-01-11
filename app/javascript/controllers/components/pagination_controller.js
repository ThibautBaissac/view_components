import { Controller } from "@hotwired/stimulus"

/**
 * Pagination component controller for enhanced accessibility and keyboard navigation.
 *
 * Features:
 * - Arrow key navigation (Left/Right for prev/next)
 * - Home/End keys (first/last page)
 * - Focus management after Turbo Frame updates
 * - Screen reader announcements
 *
 * Targets:
 * - announcement: Screen reader announcement region (optional)
 *
 * Values:
 * - currentPage: Number - Current page number
 * - totalPages: Number - Total number of pages
 * - turboFrame: String - Turbo Frame ID (optional)
 *
 * Actions:
 * - keydown: Handle keyboard navigation
 * - turbo:frame-load@window: Restore focus after Turbo updates
 *
 * @example
 *   <nav data-controller="components--pagination"
 *        data-components--pagination-current-page-value="3"
 *        data-components--pagination-total-pages-value="10"
 *        data-components--pagination-turbo-frame-value="items"
 *        data-action="keydown->components--pagination#handleKeydown turbo:frame-load@window->components--pagination#handleFrameLoad">
 *     ...
 *   </nav>
 */
export default class extends Controller {
  static targets = ["announcement"]
  static values = {
    currentPage: Number,
    totalPages: Number,
    turboFrame: String
  }

  /**
   * Initialize the controller
   */
  connect() {
    // Ensure the navigation is keyboard accessible
    if (!this.element.hasAttribute("tabindex")) {
      this.element.setAttribute("tabindex", "-1")
    }

    // Create announcement region if not present
    if (!this.hasAnnouncementTarget) {
      this.createAnnouncementRegion()
    }
  }

  /**
   * Handle keyboard navigation
   * @param {KeyboardEvent} event
   */
  handleKeydown(event) {
    // Only handle if focus is within the pagination component
    if (!this.element.contains(document.activeElement)) {
      return
    }

    switch (event.key) {
      case "ArrowLeft":
      case "ArrowUp":
        event.preventDefault()
        this.navigatePrevious()
        break
      case "ArrowRight":
      case "ArrowDown":
        event.preventDefault()
        this.navigateNext()
        break
      case "Home":
        event.preventDefault()
        this.navigateToPage(1)
        break
      case "End":
        event.preventDefault()
        this.navigateToPage(this.totalPagesValue)
        break
    }
  }

  /**
   * Navigate to previous page
   */
  navigatePrevious() {
    if (this.currentPageValue > 1) {
      const prevLink = this.element.querySelector('a[rel="prev"]')
      if (prevLink) {
        this.announce(`Navigating to page ${this.currentPageValue - 1}`)
        prevLink.click()
      }
    } else {
      this.announce("Already on first page")
    }
  }

  /**
   * Navigate to next page
   */
  navigateNext() {
    if (this.currentPageValue < this.totalPagesValue) {
      const nextLink = this.element.querySelector('a[rel="next"]')
      if (nextLink) {
        this.announce(`Navigating to page ${this.currentPageValue + 1}`)
        nextLink.click()
      }
    } else {
      this.announce("Already on last page")
    }
  }

  /**
   * Navigate to specific page
   * @param {Number} pageNumber
   */
  navigateToPage(pageNumber) {
    if (pageNumber === this.currentPageValue) {
      this.announce(`Already on page ${pageNumber}`)
      return
    }

    const pageLink = this.element.querySelector(`a[href*="page=${pageNumber}"]`)
    if (pageLink) {
      this.announce(`Navigating to page ${pageNumber}`)
      pageLink.click()
    }
  }

  /**
   * Handle Turbo Frame load to restore focus
   * @param {Event} event
   */
  handleFrameLoad(event) {
    // Only handle if this pagination's turbo frame was updated
    if (!this.hasTurboFrameValue) return

    // Check if the event is for this pagination's turbo frame
    const frameElement = event.target
    if (frameElement && frameElement.id === this.turboFrameValue) {
      // Restore focus to the pagination nav after a brief delay
      // to allow the frame to fully render
      setTimeout(() => {
        this.element.focus()

        // Update current page value if needed from URL
        if (event.detail?.fetchResponse?.url) {
          const url = new URL(event.detail.fetchResponse.url)
          const pageParam = url.searchParams.get("page")
          if (pageParam) {
            this.currentPageValue = parseInt(pageParam, 10)
            this.announce(`Page ${this.currentPageValue} of ${this.totalPagesValue} loaded`)
          }
        }
      }, 100)
    }
  }

  /**
   * Announce message to screen readers
   * @param {String} message
   */
  announce(message) {
    if (this.hasAnnouncementTarget) {
      this.announcementTarget.textContent = message
    }
  }

  /**
   * Create screen reader announcement region
   */
  createAnnouncementRegion() {
    const announcement = document.createElement("div")
    announcement.setAttribute("role", "status")
    announcement.setAttribute("aria-live", "polite")
    announcement.setAttribute("aria-atomic", "true")
    announcement.classList.add("sr-only")
    announcement.dataset.componentsPaginationTarget = "announcement"
    this.element.appendChild(announcement)
  }
}
