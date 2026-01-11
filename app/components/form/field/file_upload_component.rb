# frozen_string_literal: true

# Form::Field::FileUploadComponent
#
# A flexible file upload component with drag-and-drop support, file preview,
# and validation. Integrates with Stimulus for enhanced UX.
#
# @note Client-side validation is provided for better UX, but you MUST implement
#   server-side validation in your controller/service/form object:
#   - Validate file content_type (cannot trust client-provided MIME type)
#   - Validate file size (client-side can be bypassed)
#   - Validate file count for multiple uploads
#   - Use Active Storage validations or custom validators
#   - Scan uploaded files for malware if handling user content
#
# @example Basic usage
#   <%= render Form::Field::FileUploadComponent.new(name: "document") %>
#
# @example With label and hint
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "avatar",
#     label: "Profile Photo",
#     hint: "JPG, PNG or GIF, max 5MB"
#   ) %>
#
# @example With file type restrictions
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "document",
#     label: "Upload Document",
#     accept: ".pdf,.doc,.docx",
#     hint: "PDF or Word documents only"
#   ) %>
#
# @example With image preview
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "photo",
#     label: "Photo",
#     accept: "image/*",
#     preview: true
#   ) %>
#
# @example Multiple file upload
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "attachments[]",
#     label: "Attachments",
#     multiple: true,
#     max_files: 5
#   ) %>
#
# @example With max size validation
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "video",
#     label: "Video",
#     accept: "video/*",
#     max_size: 100.megabytes
#   ) %>
#
# @example With error state
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "document",
#     label: "Document",
#     error: "is required"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "contract",
#     label: "Signed Contract",
#     required: true
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::FileUploadComponent.new(
#     name: "locked_file",
#     label: "Locked File",
#     disabled: true
#   ) %>
#
# @example With custom icon
#   <%= render Form::Field::FileUploadComponent.new(name: "file") do |upload| %>
#     <% upload.with_icon do %>
#       <%= render Foundation::IconComponent.new(name: "document", size: :large) %>
#     <% end %>
#   <% end %>
#
class Form::Field::FileUploadComponent < Form::Field::BaseComponent
  # Slot for custom icon in the drop zone
  renders_one :icon

  # Default max file size in bytes (10MB)
  DEFAULT_MAX_SIZE = 10 * 1024 * 1024

  # Default max number of files for multiple upload
  DEFAULT_MAX_FILES = 10

  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param label [String] The label text
  # @param hint [String] Help text displayed below the component
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param size [Symbol] The component size (:small, :medium, :large)
  # @param accept [String] Accepted file types (e.g., "image/*", ".pdf,.doc")
  # @param multiple [Boolean] Whether to allow multiple file uploads
  # @param max_size [Integer] Maximum file size in bytes
  # @param max_files [Integer] Maximum number of files (for multiple uploads)
  # @param preview [Boolean] Whether to show image preview
  # @param drop_text [String] Custom text for drop zone
  # @param browse_text [String] Custom text for browse button
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    accept: nil,
    multiple: false,
    max_size: DEFAULT_MAX_SIZE,
    max_files: DEFAULT_MAX_FILES,
    preview: true,
    drop_text: nil,
    browse_text: nil,
    **options
  )
    super(name: name, **options)
    @accept = accept
    @multiple = multiple
    @max_size = max_size
    @max_files = max_files
    @preview = preview
    @drop_text = drop_text
    @browse_text = browse_text
  end

  # Whether the component allows multiple files
  # @return [Boolean]
  def multiple?
    @multiple
  end

  # Whether to show image preview
  # @return [Boolean]
  def preview?
    @preview
  end

  # The text displayed in the drop zone
  # @return [String]
  def drop_zone_text
    @drop_text || t_component(
      "drop_text.#{multiple? ? 'multiple' : 'single'}",
      default: multiple? ? "Drop files here or" : "Drop file here or"
    )
  end

  # The text for the browse button/link
  # @return [String]
  def browse_button_text
    @browse_text || t_component("browse_text", default: "browse")
  end

  # Human-readable max file size
  # @return [String]
  def human_max_size
    number_to_human_size(@max_size)
  end

  # File types description for display
  # @return [String, nil]
  def accepted_types_description
    return nil if @accept.blank?

    @accept.split(",").map(&:strip).map do |type|
      if type.start_with?(".")
        type.upcase.delete(".")
      elsif type.include?("/")
        type.split("/").last.upcase
      else
        type.upcase
      end
    end.uniq.join(", ")
  end

  private

  # CSS classes for the wrapper
  # @return [String]
  def wrapper_classes
    "form-field"
  end

  # CSS classes for the drop zone container
  # @return [String]
  def drop_zone_classes
    classes = [
      "relative border-2 border-dashed rounded-lg transition-colors duration-200",
      "flex flex-col items-center justify-center text-center cursor-pointer",
      size_drop_zone_classes
    ]

    if has_error?
      classes << "border-red-300 bg-red-50"
    elsif @disabled
      classes << "border-gray-200 bg-gray-50 cursor-not-allowed opacity-60"
    else
      classes << "border-gray-300 bg-white hover:border-blue-400 hover:bg-blue-50"
    end

    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  # Size-specific CSS classes for the drop zone
  # @return [String]
  def size_drop_zone_classes
    case @size
    when :small
      "p-4 min-h-24"
    when :medium
      "p-6 min-h-32"
    when :large
      "p-8 min-h-40"
    end
  end

  # CSS classes for the icon
  # @return [String]
  def icon_classes
    if has_error?
      "text-red-400"
    elsif @disabled
      "text-gray-300"
    else
      "text-gray-400"
    end
  end

  # CSS classes for the main text
  # @return [String]
  def text_classes
    classes = [ "text-gray-600" ]
    classes << size_text_classes
    classes.join(" ")
  end

  # Size-specific text classes
  # @return [String]
  def size_text_classes
    case @size
    when :small
      "text-xs"
    when :medium
      "text-sm"
    when :large
      "text-base"
    end
  end

  # CSS classes for the browse link
  # @return [String]
  def browse_link_classes
    if @disabled
      "text-gray-400 cursor-not-allowed"
    else
      "text-blue-600 hover:text-blue-700 font-medium underline"
    end
  end

  # CSS classes for the secondary text (file restrictions)
  # @return [String]
  def secondary_text_classes
    "text-gray-500 text-xs mt-1"
  end

  # CSS classes for the file list container
  # @return [String]
  def file_list_classes
    "mt-3 space-y-2"
  end

  # CSS classes for individual file items
  # @return [String]
  def file_item_classes
    "flex items-center justify-between p-2 bg-gray-50 rounded-lg text-sm"
  end

  # CSS classes for file item remove button
  # @return [String]
  def remove_button_classes
    "p-1 rounded-full hover:bg-gray-200 text-gray-500 hover:text-red-500 transition-colors"
  end

  # Build the hidden file input attributes
  # @return [Hash]
  def input_attributes
    attrs = {
      type: "file",
      name: @name,
      id: @id,
      class: "sr-only",
      disabled: @disabled || nil,
      required: @required || nil,
      "aria-invalid": has_error? ? "true" : nil,
      "aria-describedby": aria_describedby,
      data: {
        "components--file-upload-target": "input",
        action: "change->components--file-upload#handleFileSelect"
      }
    }
    attrs[:accept] = @accept if @accept.present?
    attrs[:multiple] = true if @multiple
    merge_html_attributes(attrs.compact)
  end

  # Data attributes for the wrapper element (Stimulus)
  # @return [Hash]
  def wrapper_data_attributes
    {
      controller: "components--file-upload",
      "components--file-upload-max-size-value": @max_size,
      "components--file-upload-max-files-value": @max_files,
      "components--file-upload-accept-value": @accept,
      "components--file-upload-multiple-value": @multiple,
      "components--file-upload-preview-value": @preview
    }
  end

  # Data attributes for the drop zone
  # @return [Hash]
  def drop_zone_data_attributes
    {
      "components--file-upload-target": "dropZone",
      action: [
        "dragenter->components--file-upload#handleDragEnter",
        "dragover->components--file-upload#handleDragOver",
        "dragleave->components--file-upload#handleDragLeave",
        "drop->components--file-upload#handleDrop",
        "click->components--file-upload#handleDropZoneClick",
        "keydown->components--file-upload#handleKeydown"
      ].join(" ")
    }
  end

  # HTML attributes for the drop zone
  # @return [Hash]
  def drop_zone_html_attributes
    attrs = {}
    attrs[:tabindex] = "0" unless @disabled
    attrs[:role] = "button"
    attrs["aria-label"] = t_component(
      "aria_label",
      default: "File upload drop zone. Press Enter or Space to browse files."
    )
    attrs
  end
end
