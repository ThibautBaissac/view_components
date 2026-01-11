# frozen_string_literal: true

# Form::Field::BaseComponent
#
# Abstract base class for form field components. Provides shared functionality
# for labels, hints, errors, sizing, and accessibility attributes.
#
# This class is not meant to be rendered directly. Subclasses should implement
# their own templates and add field-specific logic.
#
# @abstract Subclass and override {#render?} to implement a custom form field.
#
# @example Creating a custom field component
#   class Form::Field::MyFieldComponent < Form::Field::BaseComponent
#     def initialize(name:, custom_option: false, **options)
#       super(name: name, **options)
#       @custom_option = custom_option
#     end
#   end
#
class Form::Field::BaseComponent < ViewComponent::Base
  include I18nHelpers
  include HtmlAttributesRendering

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available sizes for form fields
  SIZES = %i[small medium large].freeze

  # Default size
  DEFAULT_SIZE = :medium

  # Common focus ring classes for form inputs
  INPUT_FOCUS_CLASSES = "focus:outline-none focus:ring-2 focus:ring-offset-0".freeze

  # @param name [String] The field name attribute (required)
  # @param id [String] The field id attribute (defaults to sanitized name)
  # @param value [String] The field value
  # @param label [String] The label text
  # @param placeholder [String] The placeholder text
  # @param hint [String] Help text displayed below the field
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly
  # @param autocomplete [String] The autocomplete attribute value (e.g., "email", "tel", "name")
  # @param size [Symbol] The field size (:small, :medium, :large)
  # @param html_attributes [Hash] Additional HTML attributes for the field
  def initialize(
    name:,
    id: nil,
    value: nil,
    label: nil,
    placeholder: nil,
    hint: nil,
    error: nil,
    required: false,
    disabled: false,
    readonly: false,
    autocomplete: nil,
    size: DEFAULT_SIZE,
    **html_attributes
  )
    @name = name
    @id = id || sanitize_id(name)
    @value = value
    @label = label
    @placeholder = placeholder
    @hint = hint
    @error = normalize_error(error)
    @required = required
    @disabled = disabled
    @readonly = readonly
    @autocomplete = autocomplete
    @size = size.to_sym
    @html_attributes = html_attributes

    validate_size!
  end

  # Unique ID for hint element (for aria-describedby)
  # @return [String, nil] The hint element ID or nil if no hint
  def hint_id
    "#{@id}-hint" if @hint.present?
  end

  # Unique ID for error element (for aria-describedby)
  # @return [String, nil] The error element ID or nil if no error
  def error_id
    "#{@id}-error" if has_error?
  end

  # Whether the field has an error
  # @return [Boolean]
  def has_error?
    @error.present?
  end

  # Whether the field has a label
  # @return [Boolean]
  def has_label?
    @label.present?
  end

  # Whether the field has a hint
  # @return [Boolean]
  def has_hint?
    @hint.present?
  end

  private

  # Sanitize a name attribute into a valid HTML ID
  # Converts brackets to underscores and removes trailing underscores
  # @param name [String] The name to sanitize
  # @return [String] A valid HTML ID
  def sanitize_id(name)
    name.to_s.tr("[]", "_").gsub(/__+/, "_").chomp("_")
  end

  # Normalize error to a single string
  # @param error [String, Array<String>, nil] Error message(s)
  # @return [String, nil] Normalized error string or nil
  def normalize_error(error)
    return nil if error.blank?

    Array(error).join(", ")
  end

  # Validate the size parameter
  # @raise [ArgumentError] if size is invalid
  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Valid sizes are: #{SIZES.join(', ')}"
  end

  # CSS classes for the field wrapper
  # @return [String]
  def wrapper_classes
    "form-field"
  end

  # CSS classes for the label element
  # @return [String]
  def label_classes
    classes = [ "block font-semibold text-slate-700 mb-1.5" ]
    classes << size_label_classes
    classes.join(" ")
  end

  # Size-specific CSS classes for the label
  # @return [String]
  def size_label_classes
    case @size
    when :small
      "text-xs"
    when :medium
      "text-sm"
    when :large
      "text-base"
    end
  end

  # CSS classes for the hint text
  # @return [String]
  def hint_classes
    "mt-1.5 text-slate-600 text-xs leading-relaxed"
  end

  # CSS classes for the error text
  # @return [String]
  def error_classes
    "mt-1.5 text-red-600 text-xs font-medium"
  end

  # Required field indicator
  # @return [String, nil] Returns "*" if required, nil otherwise
  def required_indicator
    "*" if @required
  end

  # Required indicator HTML with proper styling and accessibility
  # @return [String, nil] HTML-safe required indicator or nil
  def required_indicator_html
    return unless @required

    tag.span("*", class: "text-red-500 ml-0.5", "aria-hidden": "true")
  end

  # Build aria-describedby attribute value
  # Only includes hint_id when hint is actually rendered (not when error hides it)
  # @return [String, nil] Space-separated list of IDs or nil
  def aria_describedby
    ids = []
    ids << hint_id if has_hint? && !has_error?
    ids << error_id if has_error?
    ids.join(" ").presence
  end

  # Base CSS classes for input/textarea elements
  # @return [String]
  def base_field_classes
    "block w-full border-2 rounded-lg shadow-sm transition-all duration-200 " \
    "#{INPUT_FOCUS_CLASSES}"
  end

  # Size-specific CSS classes for input/textarea elements
  # @return [String]
  def size_field_classes
    case @size
    when :small
      "px-3 py-2 text-xs"
    when :medium
      "px-3.5 py-2.5 text-sm"
    when :large
      "px-4 py-3 text-base"
    end
  end

  # State-specific CSS classes for input/textarea elements
  # @return [String]
  def state_field_classes
    if has_error?
      "border-red-400 bg-red-50/50 text-red-900 placeholder-red-400 " \
      "focus:border-red-500 focus:ring-red-500 focus:bg-white"
    elsif @disabled
      "border-slate-300 bg-slate-100 text-slate-500 cursor-not-allowed"
    else
      "border-slate-300 bg-white placeholder-slate-400 " \
      "focus:border-indigo-500 focus:ring-indigo-500 hover:border-slate-400"
    end
  end

  # Base attributes common to all field types
  # @return [Hash] Base HTML attributes
  def base_field_attributes
    {
      name: @name,
      id: @id,
      placeholder: @placeholder,
      required: @required || nil,
      disabled: @disabled || nil,
      readonly: @readonly || nil,
      autocomplete: @autocomplete,
      "aria-invalid": has_error? ? "true" : nil,
      "aria-describedby": aria_describedby
    }.compact
  end

  # Merge custom HTML attributes (excluding class) into the base attributes
  # @param attrs [Hash] Base attributes to merge into
  # @return [Hash] Merged attributes
  def merge_html_attributes(attrs)
    @html_attributes.except(:class).each do |key, value|
      attrs[key] = value
    end
    attrs
  end

  # Flatten HTML attributes for rendering (handles nested data attributes)
  # Used by group components to render fieldset attributes
  # @return [String] Flattened HTML attributes string
  def flattened_html_attributes
    return "" if @html_attributes.empty?

    flatten_attributes(@html_attributes).map do |k, v|
      %(#{ERB::Util.html_escape(k.to_s)}="#{ERB::Util.html_escape(v.to_s)}")
    end.join(" ").html_safe
  end

  # Recursively flatten nested attributes (e.g., data: { controller: "foo" } => data-controller="foo")
  # @param hash [Hash] The attributes hash to flatten
  # @param prefix [String, nil] The prefix for nested keys
  # @return [Hash] The flattened attributes
  def flatten_attributes(hash, prefix = nil)
    hash.each_with_object({}) do |(k, v), result|
      key = prefix ? "#{prefix}-#{k}" : k.to_s
      if v.is_a?(Hash)
        result.merge!(flatten_attributes(v, key))
      else
        result[key] = v
      end
    end
  end

  # Shared classes for checkbox/radio input elements
  # Centralizes common styling for checkbox and radio button inputs
  # @param shape [Symbol] :square for checkbox, :circle for radio
  # @return [String] CSS classes for the input element
  def base_choice_input_classes(shape:)
    shape_class = shape == :circle ? "rounded-full" : "rounded"
    "#{shape_class} border focus:outline-none focus:ring-2 focus:ring-offset-0 " \
    "transition-colors duration-200"
  end

  # Size-specific CSS classes for checkbox/radio inputs
  # @return [String] CSS classes for the input size
  def size_choice_input_classes
    case @size
    when :small
      "h-3.5 w-3.5"
    when :medium
      "h-4 w-4"
    when :large
      "h-5 w-5"
    end
  end

  # State-specific CSS classes for checkbox/radio inputs
  # @return [String] CSS classes for the input state
  def state_choice_input_classes
    if has_error?
      "border-red-300 text-red-600 focus:border-red-500 focus:ring-red-500"
    elsif @disabled
      "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed"
    else
      "border-slate-300 text-blue-600 focus:border-blue-500 focus:ring-blue-500"
    end
  end

  # Label classes for checkbox/radio components
  # @return [String] CSS classes for the label
  def choice_label_classes
    base = "text-slate-700 cursor-pointer select-none"
    disabled = @disabled ? "cursor-not-allowed opacity-60" : ""
    size = size_choice_label_classes
    [ base, disabled, size ].compact.join(" ")
  end

  # Size-specific label classes for checkbox/radio components
  # @return [String] CSS classes for the label size
  def size_choice_label_classes
    case @size
    when :small
      "text-xs"
    when :medium
      "text-sm"
    when :large
      "text-base"
    end
  end
end
