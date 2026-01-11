# frozen_string_literal: true

# Form::Field::TextareaComponent
#
# A flexible textarea component that wraps a standard HTML textarea element
# with consistent styling, labels, hints, and error handling.
#
# @example Basic usage
#   <%= render Form::Field::TextareaComponent.new(name: "description") %>
#
# @example With label
#   <%= render Form::Field::TextareaComponent.new(
#     name: "description",
#     label: "Description"
#   ) %>
#
# @example With placeholder and hint
#   <%= render Form::Field::TextareaComponent.new(
#     name: "bio",
#     label: "Biography",
#     placeholder: "Tell us about yourself...",
#     hint: "Maximum 500 characters."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::TextareaComponent.new(
#     name: "description",
#     label: "Description",
#     error: "can't be blank"
#   ) %>
#
# @example With custom rows
#   <%= render Form::Field::TextareaComponent.new(
#     name: "content",
#     label: "Content",
#     rows: 10
#   ) %>
#
# @example With resize control
#   <%= render Form::Field::TextareaComponent.new(
#     name: "notes",
#     label: "Notes",
#     resize: :none
#   ) %>
#
# @example Required field
#   <%= render Form::Field::TextareaComponent.new(
#     name: "message",
#     label: "Message",
#     required: true
#   ) %>
#
# @example With character limit
#   <%= render Form::Field::TextareaComponent.new(
#     name: "tweet",
#     label: "Tweet",
#     maxlength: 280,
#     hint: "Maximum 280 characters."
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::TextareaComponent.new(
#     name: "readonly_field",
#     value: "Cannot edit this content.",
#     disabled: true
#   ) %>
#
# @example With French localization
#   <%= render Form::Field::TextareaComponent.new(
#     name: "description",
#     label: "Description",
#     placeholder: t("components.form.field.textarea.placeholder"),
#     hint: t("components.form.field.textarea.hint.max_characters", count: 500),
#     maxlength: 500
#   ) %>
#
class Form::Field::TextareaComponent < Form::Field::BaseComponent
  # Available resize options
  RESIZE_OPTIONS = %i[none vertical horizontal both].freeze

  # Default resize
  DEFAULT_RESIZE = :vertical

  # Default number of rows
  DEFAULT_ROWS = 4

  # @param name [String] The textarea name attribute (required)
  # @param id [String] The textarea id attribute (defaults to name)
  # @param value [String] The textarea value/content
  # @param label [String] The label text
  # @param placeholder [String] The placeholder text
  # @param hint [String] Help text displayed below the textarea
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly
  # @param size [Symbol] The textarea size (:small, :medium, :large)
  # @param rows [Integer] Number of visible text lines
  # @param cols [Integer] Visible width in characters (optional)
  # @param resize [Symbol] Resize behavior (:none, :vertical, :horizontal, :both)
  # @param maxlength [Integer] Maximum character count
  # @param minlength [Integer] Minimum character count
  # @param html_attributes [Hash] Additional HTML attributes for the textarea
  def initialize(
    name:,
    rows: DEFAULT_ROWS,
    cols: nil,
    resize: DEFAULT_RESIZE,
    maxlength: nil,
    minlength: nil,
    **options
  )
    super(name: name, **options)
    @rows = rows
    @cols = cols
    @resize = resize.to_sym
    @maxlength = maxlength
    @minlength = minlength
    validate_resize!
  end

  private

  def validate_resize!
    return if RESIZE_OPTIONS.include?(@resize)

    raise ArgumentError, "Invalid resize: #{@resize}. Valid options are: #{RESIZE_OPTIONS.join(', ')}"
  end

  def textarea_classes
    classes = [
      base_field_classes,
      size_field_classes,
      state_field_classes,
      resize_classes
    ]
    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  def resize_classes
    case @resize
    when :none
      "resize-none"
    when :vertical
      "resize-y"
    when :horizontal
      "resize-x"
    when :both
      "resize"
    end
  end

  def textarea_attributes
    attrs = base_field_attributes.merge(
      rows: @rows,
      cols: @cols,
      maxlength: @maxlength,
      minlength: @minlength,
      "aria-required": @required ? "true" : nil
    ).compact
    merge_html_attributes(attrs)
  end

  def merged_textarea_attributes
    textarea_attributes.merge(class: textarea_classes)
  end
end
