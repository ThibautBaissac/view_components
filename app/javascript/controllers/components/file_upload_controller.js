import { Controller } from "@hotwired/stimulus"

/**
 * File Upload Controller
 *
 * Handles drag-and-drop file uploads, file validation, and preview display.
 *
 * Targets:
 * - input: The hidden file input element
 * - dropZone: The drag-and-drop zone
 * - dragOverlay: Overlay shown during drag operations
 * - fileList: Container for displaying selected files
 * - fileItemTemplate: Template for file list items
 * - imagePreviewTemplate: Template for image previews
 * - fileIconTemplate: Template for file icons
 * - validationError: Container for validation error messages
 * - dropText: Text shown in drop zone
 * - browseButton: Browse button element
 *
 * Values:
 * - maxSize: Maximum file size in bytes
 * - maxFiles: Maximum number of files (for multiple uploads)
 * - accept: Accepted file types
 * - multiple: Whether multiple files are allowed
 * - preview: Whether to show image previews
 */
export default class extends Controller {
  // Error message templates (ready for i18n integration)
  static MESSAGES = {
    maxFilesExceeded: (max) => `Maximum ${max} files allowed`,
    partialUpload: (added, total, max) =>
      `Only ${added} of ${total} files added. Maximum ${max} files allowed.`,
    fileSizeExceeded: (name, size) => `"${name}" exceeds maximum size of ${size}`,
    fileTypeNotAllowed: (name) => `"${name}" is not an allowed file type`
  }
  static targets = [
    "input",
    "dropZone",
    "dragOverlay",
    "fileList",
    "fileItemTemplate",
    "imagePreviewTemplate",
    "fileIconTemplate",
    "validationError",
    "dropText",
    "browseButton",
    "iconContainer",
    "textContainer",
    "restrictions"
  ]

  static values = {
    maxSize: { type: Number, default: 10485760 }, // 10MB
    maxFiles: { type: Number, default: 10 },
    accept: { type: String, default: "" },
    multiple: { type: Boolean, default: false },
    preview: { type: Boolean, default: true }
  }

  connect() {
    this.files = []
    this.dragCounter = 0
    this.previewUrls = []
    this.isSyncing = false

    // Prevent default drag behavior on document to stop file opening
    this.handleDocumentDragOver = this.preventDefaultDrag.bind(this)
    this.handleDocumentDrop = this.preventDefaultDrag.bind(this)
    document.addEventListener('dragover', this.handleDocumentDragOver)
    document.addEventListener('drop', this.handleDocumentDrop)
  }

  disconnect() {
    this.files = []
    // Clean up object URLs to prevent memory leaks
    this.previewUrls.forEach(url => URL.revokeObjectURL(url))
    this.previewUrls = []

    // Remove document-level event listeners
    document.removeEventListener('dragover', this.handleDocumentDragOver)
    document.removeEventListener('drop', this.handleDocumentDrop)
  }

  /**
   * Prevent default drag behavior to stop browser from opening files
   * @param {DragEvent} event - The drag event
   */
  preventDefaultDrag(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  /**
   * Handle drop zone click (but not button clicks)
   * @param {Event} event - The click event
   */
  handleDropZoneClick(event) {
    // Don't trigger if clicking on the browse button
    if (this.hasBrowseButtonTarget && event.target === this.browseButtonTarget) {
      return
    }
    // Don't trigger if clicking inside the button
    if (this.hasBrowseButtonTarget && this.browseButtonTarget.contains(event.target)) {
      return
    }

    event.preventDefault()
    if (this.hasInputTarget && !this.inputTarget.disabled) {
      this.inputTarget.click()
    }
  }

  /**
   * Trigger the hidden file input when clicking browse button
   * @param {Event} event - The click event
   */
  triggerFileInput(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
    if (this.hasInputTarget && !this.inputTarget.disabled) {
      this.inputTarget.click()
    }
  }

  /**
   * Handle keyboard events on drop zone
   * @param {KeyboardEvent} event - The keyboard event
   */
  handleKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.triggerFileInput(event)
    }
  }

  /**
   * Handle file selection from file input
   * @param {Event} event - The change event
   */
  handleFileSelect(event) {
    // Prevent processing during sync to avoid infinite loops
    if (this.isSyncing) return

    const files = Array.from(event.target.files)
    this.processFiles(files)
  }

  /**
   * Handle drag enter event
   * @param {DragEvent} event - The drag event
   */
  handleDragEnter(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.inputTarget?.disabled) return

    this.dragCounter++

    if (this.hasDragOverlayTarget) {
      this.dragOverlayTarget.classList.remove("hidden")
      this.dragOverlayTarget.classList.add("flex")
    }

    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.add("border-blue-500", "bg-blue-50")
    }
  }

  /**
   * Handle drag over event
   * @param {DragEvent} event - The drag event
   */
  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.inputTarget?.disabled) return
  }

  /**
   * Handle drag leave event
   * @param {DragEvent} event - The drag event
   */
  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()

    this.dragCounter--

    if (this.dragCounter <= 0) {
      this.dragCounter = 0
      this.hideDragOverlay()
    }
  }

  /**
   * Handle drop event
   * @param {DragEvent} event - The drop event
   */
  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.inputTarget?.disabled) return

    this.dragCounter = 0
    this.hideDragOverlay()

    const files = Array.from(event.dataTransfer.files)
    this.processFiles(files)
  }

  /**
   * Process selected files
   * @param {File[]} newFiles - Array of files to process
   */
  processFiles(newFiles) {
    this.clearValidationError()

    // Filter and validate files
    const validFiles = this.validateFiles(newFiles)

    if (validFiles.length === 0) return

    // If not multiple, replace existing files
    if (!this.multipleValue) {
      this.files = validFiles.slice(0, 1)
    } else {
      // Check max files limit
      const remainingSlots = this.maxFilesValue - this.files.length
      if (remainingSlots <= 0) {
        this.showValidationError(
          this.constructor.MESSAGES.maxFilesExceeded(this.maxFilesValue)
        )
        return
      }

      const filesToAdd = validFiles.slice(0, remainingSlots)
      this.files = [...this.files, ...filesToAdd]

      if (validFiles.length > filesToAdd.length) {
        this.showValidationError(
          this.constructor.MESSAGES.partialUpload(
            filesToAdd.length,
            validFiles.length,
            this.maxFilesValue
          )
        )
      }
    }

    this.updateFileList()
    this.updateDropZoneVisibility()
    this.syncFilesToInput()
  }

  /**
   * Validate files against constraints
   * @param {File[]} files - Files to validate
   * @returns {File[]} Valid files
   */
  validateFiles(files) {
    const validFiles = []
    const errors = []

    for (const file of files) {
      // Check file size
      if (file.size > this.maxSizeValue) {
        errors.push(
          this.constructor.MESSAGES.fileSizeExceeded(
            file.name,
            this.formatFileSize(this.maxSizeValue)
          )
        )
        continue
      }

      // Check file type
      if (this.acceptValue && !this.isFileTypeAllowed(file)) {
        errors.push(this.constructor.MESSAGES.fileTypeNotAllowed(file.name))
        continue
      }

      validFiles.push(file)
    }

    if (errors.length > 0) {
      this.showValidationError(errors.join(". "))
    }

    return validFiles
  }

  /**
   * Check if file type is allowed
   * @param {File} file - File to check
   * @returns {boolean} Whether file type is allowed
   */
  isFileTypeAllowed(file) {
    if (!this.acceptValue) return true

    const acceptedTypes = this.acceptValue.split(",").map(t => t.trim().toLowerCase())

    for (const type of acceptedTypes) {
      // Check extension (e.g., ".pdf")
      if (type.startsWith(".")) {
        if (file.name.toLowerCase().endsWith(type)) return true
      }
      // Check MIME type with wildcard (e.g., "image/*")
      else if (type.endsWith("/*")) {
        const category = type.slice(0, -2)
        if (file.type.startsWith(category + "/")) return true
      }
      // Check exact MIME type
      else if (file.type.toLowerCase() === type) {
        return true
      }
    }

    return false
  }

  /**
   * Update the file list display
   */
  updateFileList() {
    if (!this.hasFileListTarget || !this.hasFileItemTemplateTarget) return

    // Clear existing list
    this.fileListTarget.innerHTML = ""

    // Show or hide file list
    if (this.files.length === 0) {
      this.fileListTarget.classList.add("hidden")
      return
    }

    this.fileListTarget.classList.remove("hidden")

    // Add file items
    this.files.forEach((file, index) => {
      const template = this.fileItemTemplateTarget.content.cloneNode(true)
      const item = template.querySelector("[data-file-item]")

      // Set file index for removal
      item.dataset.fileIndex = index

      // Set file name
      const nameEl = item.querySelector("[data-file-name]")
      if (nameEl) nameEl.textContent = file.name

      // Set file size
      const sizeEl = item.querySelector("[data-file-size]")
      if (sizeEl) sizeEl.textContent = this.formatFileSize(file.size)

      // Add preview
      const previewContainer = item.querySelector("[data-preview-container]")
      if (previewContainer) {
        if (this.previewValue && this.isImageFile(file)) {
          this.addImagePreview(file, previewContainer)
        } else {
          this.addFileIcon(previewContainer)
        }
      }

      this.fileListTarget.appendChild(template)
    })
  }

  /**
   * Check if file is an image
   * @param {File} file - File to check
   * @returns {boolean} Whether file is an image
   */
  isImageFile(file) {
    return file.type.startsWith("image/")
  }

  /**
   * Add image preview to container
   * @param {File} file - Image file
   * @param {Element} container - Container element
   */
  addImagePreview(file, container) {
    if (!this.hasImagePreviewTemplateTarget) {
      this.addFileIcon(container)
      return
    }

    const template = this.imagePreviewTemplateTarget.content.cloneNode(true)
    const img = template.querySelector("[data-preview-image]")

    if (img) {
      const reader = new FileReader()
      reader.onload = (e) => {
        img.src = e.target.result
        img.alt = file.name
        // Track URL for cleanup
        this.previewUrls.push(e.target.result)
      }
      reader.readAsDataURL(file)
    }

    container.appendChild(template)
  }

  /**
   * Add file icon to container
   * @param {Element} container - Container element
   */
  addFileIcon(container) {
    if (!this.hasFileIconTemplateTarget) return

    const template = this.fileIconTemplateTarget.content.cloneNode(true)
    container.appendChild(template)
  }

  /**
   * Remove a file from the list
   * @param {Event} event - The click event
   */
  removeFile(event) {
    event.preventDefault()
    event.stopPropagation()

    const item = event.target.closest("[data-file-item]")
    if (!item) return

    const index = parseInt(item.dataset.fileIndex, 10)
    if (isNaN(index)) return

    this.files.splice(index, 1)
    this.updateFileList()
    this.updateDropZoneVisibility()
    this.syncFilesToInput()
    this.clearValidationError()
  }

  /**
   * Update drop zone visibility based on file count
   */
  updateDropZoneVisibility() {
    if (!this.hasDropZoneTarget) return

    // For single file, hide drop zone when file is selected
    if (!this.multipleValue && this.files.length > 0) {
      this.dropZoneTarget.classList.add("hidden")
    } else {
      this.dropZoneTarget.classList.remove("hidden")
    }
  }

  /**
   * Sync files to the file input
   * Note: We can't directly set files on input, so we use DataTransfer
   */
  syncFilesToInput() {
    if (!this.hasInputTarget) return

    // Set flag to prevent recursive processing
    this.isSyncing = true

    const dataTransfer = new DataTransfer()
    this.files.forEach(file => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files

    this.isSyncing = false

    // Dispatch change event for form integration
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  /**
   * Hide drag overlay
   */
  hideDragOverlay() {
    if (this.hasDragOverlayTarget) {
      this.dragOverlayTarget.classList.add("hidden")
      this.dragOverlayTarget.classList.remove("flex")
    }

    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.remove("border-blue-500", "bg-blue-50")
    }
  }

  /**
   * Show validation error
   * @param {string} message - Error message
   */
  showValidationError(message) {
    if (!this.hasValidationErrorTarget) return

    this.validationErrorTarget.textContent = message
    this.validationErrorTarget.classList.remove("hidden")
  }

  /**
   * Clear validation error
   */
  clearValidationError() {
    if (!this.hasValidationErrorTarget) return

    this.validationErrorTarget.textContent = ""
    this.validationErrorTarget.classList.add("hidden")
  }

  /**
   * Format file size to human readable string
   * @param {number} bytes - File size in bytes
   * @returns {string} Formatted file size
   */
  formatFileSize(bytes) {
    if (bytes === 0) return "0 Bytes"

    const k = 1024
    const sizes = ["Bytes", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i]
  }
}
