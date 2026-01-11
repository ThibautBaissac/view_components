import { Controller } from "@hotwired/stimulus"

/**
 * Kanban Drag Controller
 *
 * Handles drag-and-drop functionality for kanban lead cards.
 * Allows leads to be dragged between status columns and updates via PATCH request.
 *
 * Targets:
 *   - card: Individual lead cards (draggable)
 *   - dropZone: Drop zones for each status column
 *
 * Values:
 *   - leadId: ID of the lead being dragged
 *   - currentStatus: Current status of the lead
 *   - updateUrl: URL to PATCH for updating lead status
 *
 * Actions:
 *   - dragStart(event): Initiates drag operation
 *   - dragEnd(event): Cleans up after drag operation
 *   - dragOver(event): Allows dropping by preventing default
 *   - dragEnter(event): Visual feedback when entering drop zone
 *   - dragLeave(event): Removes visual feedback when leaving drop zone
 *   - drop(event): Handles drop and updates lead status
 *
 * Usage:
 *   <div data-controller="components--kanban-drag">
 *     <div data-components--kanban-drag-target="card"
 *          data-lead-id="123"
 *          data-status="nouveau"
 *          draggable="true"
 *          data-action="dragstart->components--kanban-drag#dragStart
 *                       dragend->components--kanban-drag#dragEnd">
 *       Card content
 *     </div>
 *
 *     <div data-components--kanban-drag-target="dropZone"
 *          data-status="contacted"
 *          data-action="dragover->components--kanban-drag#dragOver
 *                       dragenter->components--kanban-drag#dragEnter
 *                       dragleave->components--kanban-drag#dragLeave
 *                       drop->components--kanban-drag#drop">
 *       Drop zone
 *     </div>
 *   </div>
 */
export default class extends Controller {
  static targets = ["card", "dropZone"]

  /**
   * Stores data about the dragged item
   */
  draggedData = null

  /**
   * Initiates drag operation
   * @param {DragEvent} event - The drag event
   */
  dragStart(event) {
    const card = event.currentTarget
    const leadId = card.dataset.leadId
    const currentStatus = card.dataset.status

    // Store drag data
    this.draggedData = { leadId, currentStatus, card }

    // Set data transfer for accessibility
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", leadId)

    // Visual feedback
    card.classList.add("opacity-50")
    card.setAttribute("aria-grabbed", "true")

    // Announce to screen readers
    this.announceToScreenReader(`Déplacement du lead ${leadId} depuis ${this.formatStatus(currentStatus)}`)
  }

  /**
   * Cleans up after drag operation
   * @param {DragEvent} event - The drag event
   */
  dragEnd(event) {
    const card = event.currentTarget

    // Remove visual feedback
    card.classList.remove("opacity-50")
    card.setAttribute("aria-grabbed", "false")

    // Clear all drop zone highlights
    this.dropZoneTargets.forEach(zone => {
      zone.classList.remove("bg-blue-100", "border-2", "border-blue-500", "border-dashed")
    })
  }

  /**
   * Allows dropping by preventing default behavior
   * @param {DragEvent} event - The drag event
   */
  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  /**
   * Visual feedback when entering drop zone
   * @param {DragEvent} event - The drag event
   */
  dragEnter(event) {
    const dropZone = event.currentTarget
    const targetStatus = dropZone.dataset.status

    // Don't highlight if dropping in same column
    if (this.draggedData && targetStatus !== this.draggedData.currentStatus) {
      dropZone.classList.add("bg-blue-100", "border-2", "border-blue-500", "border-dashed")
    }
  }

  /**
   * Removes visual feedback when leaving drop zone
   * @param {DragEvent} event - The drag event
   */
  dragLeave(event) {
    const dropZone = event.currentTarget
    dropZone.classList.remove("bg-blue-100", "border-2", "border-blue-500", "border-dashed")
  }

  /**
   * Handles drop and updates lead status via PATCH request
   * @param {DragEvent} event - The drag event
   */
  async drop(event) {
    event.preventDefault()

    const dropZone = event.currentTarget
    const targetStatus = dropZone.dataset.status

    // Remove highlight
    dropZone.classList.remove("bg-blue-100", "border-2", "border-blue-500", "border-dashed")

    if (!this.draggedData) return

    const { leadId, currentStatus, card } = this.draggedData

    // Don't update if dropped in same column
    if (targetStatus === currentStatus) {
      this.announceToScreenReader("Lead non déplacé - même statut")
      return
    }

    try {
      // Send PATCH request to update lead status
      const response = await fetch(`/leads/${leadId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCsrfToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({
          lead: { status: targetStatus }
        })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      // Move card to new column in DOM
      const cardContainer = dropZone.querySelector("[data-kanban-cards]")
      if (cardContainer) {
        // Remove empty state if it exists
        const emptyState = cardContainer.querySelector('.text-slate-400')
        if (emptyState && emptyState.textContent.includes('Aucun lead')) {
          emptyState.remove()
        }

        cardContainer.appendChild(card)
      }

      // Update card's status attribute
      card.dataset.status = targetStatus

      // Update the status badge inside the card
      this.updateCardStatusBadge(card, targetStatus)

      // Update the dropdown select value
      this.updateCardDropdown(card, targetStatus)

      // Update counts
      this.updateColumnCounts()

      // Handle empty states
      this.updateEmptyStates()

      // Announce success to screen readers
      this.announceToScreenReader(
        `Lead ${leadId} déplacé de ${this.formatStatus(currentStatus)} vers ${this.formatStatus(targetStatus)}`
      )
    } catch (error) {
      console.error("Error updating lead status:", error)
      this.announceToScreenReader("Erreur lors de la mise à jour du statut")

      // Could add error notification UI here
      alert("Une erreur est survenue lors de la mise à jour du statut du lead")
    } finally {
      this.draggedData = null
    }
  }

  /**
   * Gets CSRF token from meta tag
   * @returns {string} The CSRF token
   */
  getCsrfToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ""
  }

  /**
   * Updates lead count displays in column headers
   */
  updateColumnCounts() {
    this.dropZoneTargets.forEach(zone => {
      const status = zone.dataset.status
      const cardContainer = zone.querySelector("[data-kanban-cards]")
      const count = cardContainer ? cardContainer.children.length : 0
      const countElement = zone.querySelector("[data-lead-count]")

      if (countElement) {
        countElement.textContent = count
      }
    })
  }

  /**
   * Announces message to screen readers via aria-live region
   * @param {string} message - The message to announce
   */
  announceToScreenReader(message) {
    let liveRegion = document.querySelector("[data-kanban-live-region]")

    if (!liveRegion) {
      liveRegion = document.createElement("div")
      liveRegion.setAttribute("role", "status")
      liveRegion.setAttribute("aria-live", "polite")
      liveRegion.setAttribute("aria-atomic", "true")
      liveRegion.setAttribute("data-kanban-live-region", "")
      liveRegion.className = "sr-only"
      document.body.appendChild(liveRegion)
    }

    liveRegion.textContent = message
  }

  /**
   * Formats status for screen reader announcements
   * @param {string} status - The status to format
   * @returns {string} Formatted status in French
   */
  formatStatus(status) {
    const statusMap = {
      nouveau: "Nouveau",
      contacted: "Contacté",
      proposal_sent: "Proposition envoyée",
      won: "Gagné",
      lost: "Perdu"
    }
    return statusMap[status] || status
  }

  /**
   * Updates the status badge inside a card
   * @param {HTMLElement} card - The card element
   * @param {string} status - The new status
   */
  updateCardStatusBadge(card, status) {
    const badge = card.querySelector('.bg-blue-100, .bg-yellow-100, .bg-purple-100, .bg-green-100, .bg-red-100')
    if (!badge) return

    // Remove all status color classes
    badge.classList.remove(
      'bg-blue-100', 'text-blue-800',
      'bg-yellow-100', 'text-yellow-800',
      'bg-purple-100', 'text-purple-800',
      'bg-green-100', 'text-green-800',
      'bg-red-100', 'text-red-800'
    )

    // Add new status color classes
    const statusClasses = {
      nouveau: ['bg-blue-100', 'text-blue-800'],
      contacted: ['bg-yellow-100', 'text-yellow-800'],
      proposal_sent: ['bg-purple-100', 'text-purple-800'],
      won: ['bg-green-100', 'text-green-800'],
      lost: ['bg-red-100', 'text-red-800']
    }

    const classes = statusClasses[status] || ['bg-blue-100', 'text-blue-800']
    badge.classList.add(...classes)

    // Update badge text
    badge.textContent = this.formatStatus(status)
  }

  /**
   * Updates the dropdown select value inside a card
   * @param {HTMLElement} card - The card element
   * @param {string} status - The new status
   */
  updateCardDropdown(card, status) {
    const select = card.querySelector('select[name="lead[status]"]')
    if (!select) return

    // Map status to dropdown value
    const statusValues = {
      nouveau: "nouveau",
      contacted: "contacted",
      proposal_sent: "proposal_sent",
      won: "won",
      lost: "lost"
    }

    select.value = statusValues[status] || status
  }

  /**
   * Shows or hides empty state messages in columns
   */
  updateEmptyStates() {
    this.dropZoneTargets.forEach(zone => {
      const cardContainer = zone.querySelector("[data-kanban-cards]")
      if (!cardContainer) return

      const cards = cardContainer.querySelectorAll('[data-lead-id]')
      const emptyState = cardContainer.querySelector('.text-slate-400')

      if (cards.length === 0 && !emptyState) {
        // Show empty state
        const emptyDiv = document.createElement('div')
        emptyDiv.className = 'flex items-center justify-center h-32 text-slate-400 text-sm'
        emptyDiv.textContent = 'Aucun lead pour le moment'
        cardContainer.appendChild(emptyDiv)
      } else if (cards.length > 0 && emptyState) {
        // Hide empty state
        emptyState.remove()
      }
    })
  }
}
