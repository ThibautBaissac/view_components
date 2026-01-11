# frozen_string_literal: true

# @label Form::Field::FileUpload
# @logical_path Form/Field
# @note
#   A flexible file upload component with drag-and-drop support, file preview,
#   and validation. Integrates with Stimulus for enhanced UX including:
#   - Drag and drop files into the drop zone
#   - File type validation (accept attribute)
#   - File size validation
#   - Multiple file support with max count
#   - Image preview for image files
#   - Remove files functionality
class Form::Field::FileUploadComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   Supports single file upload with 10MB default max size.
  #   Try dragging and dropping a file onto the drop zone!
  def default
    render(Form::Field::FileUploadComponent.new(name: "document"))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the file upload field.
  #   The label is automatically associated with the input for accessibility.
  def with_label
    render(Form::Field::FileUploadComponent.new(
      name: "attachment",
      label: "Upload Document"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the component.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Contract Document",
      hint: "Please upload the signed contract in PDF format."
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::FileUploadComponent.new(
      name: "resume",
      label: "Resume",
      required: true,
      hint: "This field is required."
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The input is marked as invalid for screen readers.
  def with_error
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document",
      error: "is required"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::FileUploadComponent.new(
      name: "photo",
      label: "Profile Photo",
      error: [ "is required", "must be an image file" ]
    ))
  end

  # @label Image Upload
  # @note
  #   Restrict file types to images only using the accept attribute.
  #   Image files will show a preview thumbnail after selection.
  def image_upload
    render(Form::Field::FileUploadComponent.new(
      name: "avatar",
      label: "Profile Photo",
      accept: "image/*",
      hint: "JPG, PNG or GIF"
    ))
  end

  # @label PDF Documents
  # @note
  #   Restrict to PDF files only using specific extension.
  def pdf_only
    render(Form::Field::FileUploadComponent.new(
      name: "contract",
      label: "Signed Contract",
      accept: ".pdf",
      hint: "PDF files only"
    ))
  end

  # @label Multiple File Types
  # @note
  #   Accept multiple specific file types using extensions or MIME types.
  def multiple_types
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document Upload",
      accept: ".pdf,.doc,.docx,application/msword",
      hint: "PDF or Word documents"
    ))
  end

  # @label Multiple Files
  # @note
  #   Allow uploading multiple files at once.
  #   Users can select multiple files or drag and drop several files together.
  def multiple_files
    render(Form::Field::FileUploadComponent.new(
      name: "attachments[]",
      label: "Attachments",
      multiple: true,
      hint: "You can upload multiple files at once"
    ))
  end

  # @label Multiple Images
  # @note
  #   Upload multiple images with preview.
  #   Each image will show a thumbnail preview.
  def multiple_images
    render(Form::Field::FileUploadComponent.new(
      name: "photos[]",
      label: "Photo Gallery",
      accept: "image/*",
      multiple: true,
      max_files: 10,
      hint: "Upload up to 10 photos"
    ))
  end

  # @label With Max Files Limit
  # @note
  #   Limit the number of files that can be uploaded.
  #   The component will prevent adding more files once the limit is reached.
  def max_files
    render(Form::Field::FileUploadComponent.new(
      name: "documents[]",
      label: "Supporting Documents",
      multiple: true,
      max_files: 3,
      hint: "Maximum 3 files allowed"
    ))
  end

  # @label With Max Size
  # @note
  #   Set a maximum file size limit (in bytes).
  #   Files exceeding this size will be rejected with an error message.
  def max_size
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document",
      max_size: 2 * 1024 * 1024, # 2MB
      hint: "Maximum file size: 2 MB"
    ))
  end

  # @label Large Files
  # @note
  #   Support larger file uploads like videos.
  def large_files
    render(Form::Field::FileUploadComponent.new(
      name: "video",
      label: "Video Upload",
      accept: "video/*",
      max_size: 100 * 1024 * 1024, # 100MB
      hint: "Video files up to 100 MB"
    ))
  end

  # @label Without Preview
  # @note
  #   Disable image preview to show just file icon and name.
  def without_preview
    render(Form::Field::FileUploadComponent.new(
      name: "photo",
      label: "Photo",
      accept: "image/*",
      preview: false,
      hint: "Image preview disabled"
    ))
  end

  # @label Small Size
  # @note
  #   Compact variant with smaller padding and text.
  def small_size
    render(Form::Field::FileUploadComponent.new(
      name: "attachment",
      label: "Attachment",
      size: :small,
      hint: "Small size variant"
    ))
  end

  # @label Medium Size (Default)
  # @note
  #   Default size with balanced spacing.
  def medium_size
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document",
      size: :medium,
      hint: "Medium size variant (default)"
    ))
  end

  # @label Large Size
  # @note
  #   Larger variant with more prominent drop zone.
  def large_size
    render(Form::Field::FileUploadComponent.new(
      name: "file",
      label: "File Upload",
      size: :large,
      hint: "Large size variant"
    ))
  end

  # @label Custom Drop Text
  # @note
  #   Customize the text displayed in the drop zone.
  def custom_drop_text
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document",
      drop_text: "Drag your document here or",
      browse_text: "click to select"
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled upload field that cannot be interacted with.
  #   The drop zone and browse button are both disabled.
  def disabled
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Locked Document",
      disabled: true,
      hint: "This field is disabled"
    ))
  end

  # @label With Custom Icon
  # @note
  #   Replace the default upload icon with a custom icon.
  def with_custom_icon
    render(Form::Field::FileUploadComponent.new(
      name: "document",
      label: "Document Upload"
    )) do |upload|
      upload.with_icon do
        render(Foundation::IconComponent.new(name: "document-text", size: :large))
      end
    end
  end

  # @label Complete Example
  # @note
  #   A fully configured file upload with all common options.
  #   Shows label, required indicator, file restrictions, and hint.
  def complete_example
    render(Form::Field::FileUploadComponent.new(
      name: "profile_documents[]",
      label: "Profile Documents",
      required: true,
      multiple: true,
      max_files: 5,
      max_size: 10 * 1024 * 1024, # 10MB
      accept: ".pdf,.jpg,.jpeg,.png",
      hint: "Upload your profile documents (ID, resume, certificates). PDF or images only, max 10 MB per file."
    ))
  end

  # @label Form Context
  # @note
  #   Example showing the file upload within a complete form context.
  #   This demonstrates how it integrates with other form fields.
  def in_form_context
    render_with_template(locals: {})
  end

  # @label Multiple Uploads
  # @note
  #   Example showing multiple different file upload fields in one form.
  def multiple_uploads
    render_with_template(locals: {})
  end

  # @label Grid Layout
  # @note
  #   Example showing file uploads in a grid layout for better space usage.
  def grid_layout
    render_with_template(locals: {})
  end
end
