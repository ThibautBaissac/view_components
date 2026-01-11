# frozen_string_literal: true

# Form::Field::CheckboxComponent
#
# A flexible checkbox input component that provides consistent styling,
# labels, hints, error handling, and accessibility features.
# Supports checked/unchecked states, custom values, and label positioning.
#
# Hidden Field Behavior:
#   By default, a hidden field with value "0" is included before the checkbox.
#   This ensures Rails receives a value when the checkbox is unchecked.
#   Without it, unchecked checkboxes don't submit any value.
#   Set include_hidden: false when using checkboxes in arrays or when
#   you need different unchecked behavior.
#
# Note on readonly:
#   The readonly attribute is not officially supported on checkbox inputs in HTML5.
#   Use disabled: true for non-editable checkboxes instead.
#
# @example Basic usage
#   <%= render Form::Field::CheckboxComponent.new(name: "terms") %>
#
# @example With label
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "terms",
#     label: "I agree to the terms and conditions"
#   ) %>
#
# @example Checked by default
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "newsletter",
#     label: "Subscribe to newsletter",
#     checked: true
#   ) %>
#
# @example With custom value
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "preference",
#     label: "Enable notifications",
#     value: "notifications_enabled"
#   ) %>
#
# @example With hint
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "marketing",
#     label: "Receive marketing emails",
#     hint: "You can unsubscribe at any time."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "terms",
#     label: "I agree to the terms",
#     error: "must be accepted"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "terms",
#     label: "I accept the terms",
#     required: true
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::CheckboxComponent.new(
#     name: "locked_option",
#     label: "This option is locked",
#     checked: true,
#     disabled: true
#   ) %>
#
# @example With label slot for custom content
#   <%= render Form::Field::CheckboxComponent.new(name: "terms") do |checkbox| %>
#     <% checkbox.with_label_content do %>
#       I agree to the <a href="/terms" class="text-blue-600 underline">terms and conditions</a>
#     <% end %>
#   <% end %>
#
class Form::Field::CheckboxComponent < Form::Field::BaseComponent
  # Slot for custom label content (allows HTML like links)
  renders_one :label_content

  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param value [String] The value when checked (defaults to "1")
  # @param checked [Boolean] Whether the checkbox is checked
  # @param label [String] The label text
  # @param hint [String] Help text displayed below the checkbox
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly (Note: not standard for checkboxes, use disabled instead)
  # @param size [Symbol] The checkbox size (:small, :medium, :large)
  # @param include_hidden [Boolean] Whether to include a hidden field for unchecked value
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    value: "1",
    checked: false,
    include_hidden: true,
    **options
  )
    # Remove placeholder as it doesn't apply to checkboxes
    options.delete(:placeholder)
    super(name: name, value: value, **options)
    @checked = checked
    @include_hidden = include_hidden
  end

  # Whether the checkbox is checked
  # @return [Boolean]
  def checked?
    @checked
  end

  # Whether to include the hidden field
  # @return [Boolean]
  def include_hidden?
    @include_hidden
  end

  # Whether the label should be rendered (either via prop or slot)
  # Overrides parent method to include label_content slot detection
  # @return [Boolean] true if label prop or label_content slot is provided
  def has_label?
    @label.present? || label_content?
  end

  private

  # CSS classes for the field wrapper - horizontal layout for checkbox
  # @return [String]
  def wrapper_classes
    "form-field"
  end

  # CSS classes for the checkbox container (input + label inline)
  # @return [String]
  def checkbox_container_classes
    "flex items-start gap-2"
  end

  # CSS classes for the checkbox input
  # @return [String]
  def checkbox_classes
    @checkbox_classes ||= begin
      classes = [
        base_checkbox_classes,
        size_checkbox_classes,
        state_checkbox_classes
      ]
      classes << @html_attributes[:class] if @html_attributes[:class]
      classes.compact.join(" ")
    end
  end

  # Base CSS classes for checkbox
  # @return [String]
  def base_checkbox_classes
    "rounded border focus:outline-none focus:ring-2 focus:ring-offset-0 " \
    "transition-colors duration-200"
  end

  # Size-specific CSS classes for checkbox
  # Delegates to BaseComponent's size_choice_input_classes
  # @return [String]
  def size_checkbox_classes
    size_choice_input_classes
  end

  # State-specific CSS classes for checkbox
  # Delegates to BaseComponent's state_choice_input_classes
  # @return [String]
  def state_checkbox_classes
    state_choice_input_classes
  end

  # CSS classes for the label element - inline with checkbox
  # @return [String]
  def label_classes
    classes = [ "font-medium text-slate-700 select-none" ]
    classes << size_label_classes
    classes << "cursor-not-allowed opacity-60" if @disabled
    classes << "cursor-pointer" unless @disabled
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

  # CSS classes for the checkbox input wrapper (for alignment)
  # @return [String]
  def checkbox_input_wrapper_classes
    classes = [ "flex items-center" ]
    # Adjust top padding based on size to align with first line of label
    classes << size_input_wrapper_classes
    classes.join(" ")
  end

  # Size-specific padding for input wrapper alignment
  # @return [String]
  def size_input_wrapper_classes
    case @size
    when :small
      "h-4"
    when :medium
      "h-5"
    when :large
      "h-6"
    end
  end

  # Size-aware left margin for hints and errors to align with label
  # @return [String]
  def hint_error_margin_classes
    case @size
    when :small
      "ml-5"  # 3.5 (checkbox) + 0.5rem (gap)
    when :medium
      "ml-6"  # 4 (checkbox) + 0.5rem (gap)
    when :large
      "ml-7"  # 5 (checkbox) + 0.5rem (gap)
    end
  end

  # Checkbox input attributes
  # @return [Hash]
  def checkbox_attributes
    attrs = {
      type: "checkbox",
      name: @name,
      id: @id,
      value: @value,
      checked: @checked || nil,
      required: @required || nil,
      disabled: @disabled || nil,
      "aria-invalid": has_error? ? "true" : nil,
      "aria-describedby": aria_describedby
    }.compact
    merge_html_attributes(attrs)
  end

  # Merged checkbox attributes with classes
  # @return [Hash]
  def merged_checkbox_attributes
    checkbox_attributes.merge(class: checkbox_classes)
  end
end
