# frozen_string_literal: true

# Form::Field::RadioComponent
#
# A flexible radio button input component that provides consistent styling,
# labels, hints, error handling, and accessibility features.
# Supports checked/unchecked states and custom values.
#
# Radio buttons are typically used in groups where only one option can be selected.
# For a group of radio buttons, use RadioGroupComponent instead.
#
# Note on readonly:
#   The readonly attribute is not officially supported on radio inputs in HTML5.
#   Use disabled: true for non-editable radio buttons instead.
#
# @example Basic usage
#   <%= render Form::Field::RadioComponent.new(name: "plan", value: "basic") %>
#
# @example With label
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "pro",
#     label: "Pro Plan - $19/month"
#   ) %>
#
# @example Checked by default
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "basic",
#     label: "Basic Plan",
#     checked: true
#   ) %>
#
# @example With hint
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "enterprise",
#     label: "Enterprise Plan",
#     hint: "Contact us for custom pricing and features."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "basic",
#     label: "Basic Plan",
#     error: "Please select a plan"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "pro",
#     label: "Pro Plan",
#     required: true
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::RadioComponent.new(
#     name: "plan",
#     value: "legacy",
#     label: "Legacy Plan (no longer available)",
#     disabled: true
#   ) %>
#
# @example With label slot for custom content
#   <%= render Form::Field::RadioComponent.new(name: "plan", value: "pro") do |radio| %>
#     <% radio.with_label_content do %>
#       Pro Plan - <span class="text-green-600 font-semibold">$19/month</span>
#     <% end %>
#   <% end %>
#
class Form::Field::RadioComponent < Form::Field::BaseComponent
  # Slot for custom label content (allows HTML like formatted prices)
  renders_one :label_content

  # @param name [String] The input name attribute (required)
  # @param value [String] The value when selected (required for radio buttons)
  # @param id [String] The input id attribute (defaults to name_value)
  # @param checked [Boolean] Whether the radio is selected
  # @param label [String] The label text
  # @param hint [String] Help text displayed below the radio
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly (Note: not standard for radios, use disabled instead)
  # @param size [Symbol] The radio size (:small, :medium, :large)
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    value:,
    checked: false,
    **options
  )
    # Remove placeholder as it doesn't apply to radio buttons
    options.delete(:placeholder)

    # Generate a unique ID from name and value if not provided
    default_id = "#{sanitize_id(name)}_#{sanitize_id(value.to_s)}"
    options[:id] ||= default_id

    super(name: name, value: value, **options)
    @checked = checked
  end

  # Whether the radio is checked
  # @return [Boolean]
  def checked?
    @checked
  end

  # Whether the label should be rendered (either via prop or slot)
  # Overrides parent method to include label_content slot detection
  # @return [Boolean] true if label prop or label_content slot is provided
  def has_label?
    @label.present? || label_content?
  end

  private

  # Sanitize a value into a valid HTML ID segment
  # Extends BaseComponent#sanitize_id with additional character sanitization
  # to handle special characters in radio button values
  # @param str [String] The string to sanitize
  # @return [String] A valid ID segment
  def sanitize_id(str)
    # Use parent implementation then sanitize remaining special characters
    super(str).gsub(/[^a-zA-Z0-9_-]/, "_")
  end

  # CSS classes for the field wrapper - horizontal layout for radio
  # @return [String]
  def wrapper_classes
    "form-field"
  end

  # CSS classes for the radio container (input + label inline)
  # @return [String]
  def radio_container_classes
    "flex items-start gap-2"
  end

  # CSS classes for the radio input
  # @return [String]
  def radio_classes
    @radio_classes ||= begin
      classes = [
        base_radio_classes,
        size_radio_classes,
        state_radio_classes
      ]
      classes << @html_attributes[:class] if @html_attributes[:class]
      classes.compact.join(" ")
    end
  end

  # Base CSS classes for radio
  # @return [String]
  def base_radio_classes
    "rounded-full border focus:outline-none focus:ring-2 focus:ring-offset-0 " \
    "transition-colors duration-200"
  end

  # Size-specific CSS classes for radio
  # @return [String]
  def size_radio_classes
    case @size
    when :small
      "h-3.5 w-3.5"
    when :medium
      "h-4 w-4"
    when :large
      "h-5 w-5"
    end
  end

  # State-specific CSS classes for radio
  # @return [String]
  def state_radio_classes
    if has_error?
      "border-red-300 text-red-600 focus:border-red-500 focus:ring-red-500"
    elsif @disabled
      "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed"
    else
      "border-slate-300 text-blue-600 focus:border-blue-500 focus:ring-blue-500"
    end
  end

  # CSS classes for the label element - inline with radio
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

  # CSS classes for the radio input wrapper (for alignment)
  # @return [String]
  def radio_input_wrapper_classes
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
      "ml-5"  # 3.5 (radio) + 0.5rem (gap)
    when :medium
      "ml-6"  # 4 (radio) + 0.5rem (gap)
    when :large
      "ml-7"  # 5 (radio) + 0.5rem (gap)
    end
  end

  # Radio input attributes
  # @return [Hash]
  def radio_attributes
    attrs = {
      type: "radio",
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

  # Merged radio attributes with classes
  # @return [Hash]
  def merged_radio_attributes
    radio_attributes.merge(class: radio_classes)
  end
end
