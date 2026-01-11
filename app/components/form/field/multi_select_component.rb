# frozen_string_literal: true

# Form::Field::MultiSelectComponent
#
# A modern multi-select component with dropdown, search, and tag/chip interface for better UX.
# Click the button to open a searchable dropdown. Selected items appear as removable chips.
# Uses Stimulus controller for interactive tag management, search, and removal.
#
# @example Basic usage
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "tags[]",
#     options: ["Ruby", "Rails", "JavaScript"]
#   ) %>
#
# @example With label and hint
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "skills[]",
#     label: "Skills",
#     options: ["Ruby", "Rails", "JavaScript", "Python"],
#     hint: "Select all that apply"
#   ) %>
#
# @example With label-value pairs
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "tags[]",
#     options: [
#       ["Ruby Programming", "ruby"],
#       ["Ruby on Rails", "rails"],
#       ["JavaScript", "js"]
#     ]
#   ) %>
#
# @example With selected values
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "tags[]",
#     label: "Tags",
#     options: ["Ruby", "Rails", "JavaScript"],
#     value: ["Ruby", "Rails"]
#   ) %>
#
# @example With grouped options
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "technologies[]",
#     label: "Technologies",
#     options: {
#       "Backend" => [["Ruby", "ruby"], ["Python", "python"], ["Go", "go"]],
#       "Frontend" => [["JavaScript", "js"], ["TypeScript", "ts"], ["React", "react"]]
#     }
#   ) %>
#
# @example With error state
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "tags[]",
#     label: "Tags",
#     options: ["Ruby", "Rails"],
#     error: "must select at least one"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::MultiSelectComponent.new(
#     name: "categories[]",
#     label: "Categories",
#     options: ["Tech", "Sports", "Music"],
#     required: true
#   ) %>
#
class Form::Field::MultiSelectComponent < Form::Field::BaseComponent
  # @param name [String] The field name attribute (required, should end with [])
  # @param options [Array, Hash] The options (simple array, label-value pairs, or grouped options hash)
  # @param id [String] The field id attribute (defaults to sanitized name)
  # @param value [Array] The selected values
  # @param label [String] The label text
  # @param placeholder [String] Placeholder text for the search input
  # @param hint [String] Help text displayed below the field
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param size [Symbol] The field size (:small, :medium, :large)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    name:,
    options: [],
    placeholder: nil,
    **base_options
  )
    super(name: name, **base_options)
    @options = options
    @placeholder = placeholder || t_component("default_placeholder", default: "Search...")
    @value = Array(@value) # Ensure value is always an array
  end

  # Check if options are grouped (Hash with arrays as values)
  # @return [Boolean]
  def grouped_options?
    @options.is_a?(Hash)
  end

  # Check if a specific value is selected
  # @param option_value [String] The value to check
  # @return [Boolean]
  def selected?(option_value)
    @value.include?(option_value.to_s)
  end

  # Get all selected options as [label, value] pairs
  # @return [Array<Array>] Selected [label, value] pairs
  def selected_options
    all_options = grouped_options? ? @options.values.flatten(1) : @options
    normalized = normalize_array_options(all_options)

    normalized.select { |_label, value| selected?(value) }
  end

  private

  def wrapper_classes
    "form-field"
  end

  def trigger_button_classes
    classes = [
      "relative flex items-center justify-between w-full text-left",
      "border rounded-md shadow-sm",
      "transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-offset-0",
      trigger_size_classes
    ]
    classes << trigger_state_classes
    classes.join(" ")
  end

  def trigger_state_classes
    if has_error?
      "border-red-300 bg-white hover:border-red-400 focus:border-red-500 focus:ring-red-500 cursor-pointer"
    elsif @disabled
      "border-gray-200 bg-gray-50 cursor-not-allowed"
    else
      "border-gray-300 bg-white hover:border-gray-400 focus:border-blue-500 focus:ring-blue-500 cursor-pointer"
    end
  end

  def dropdown_classes
    [
      "absolute z-10 mt-1 w-full",
      "bg-white border border-gray-300 rounded-md shadow-lg",
      "hidden"
    ].join(" ")
  end

  def option_classes
    [
      "flex items-center justify-between cursor-pointer",
      "hover:bg-gray-50 transition-colors duration-150",
      option_size_classes
    ].join(" ")
  end

  # Size-specific classes for trigger button
  # @return [String]
  def trigger_size_classes
    case @size
    when :small
      "px-2.5 py-1.5 text-xs"
    when :medium
      "px-3 py-2 text-sm"
    when :large
      "px-4 py-3 text-base"
    end
  end

  # Size-specific classes for option items
  # @return [String]
  def option_size_classes
    case @size
    when :small
      "px-2.5 py-1.5 text-xs"
    when :medium
      "px-3 py-2 text-sm"
    when :large
      "px-4 py-3 text-base"
    end
  end

  # Render checkbox icon for selected state
  # @param selected [Boolean] Whether the option is selected
  # @return [String] HTML safe icon component
  def checkbox_icon(selected)
    if selected
      render(Foundation::IconComponent.new(
        name: "check-circle",
        variant: :solid,
        size: :medium,
        color: :primary
      ))
    else
      # Empty circle icon (custom SVG for unselected state)
      render(Foundation::IconComponent.new(
        custom: '<svg class="w-5 h-5 text-gray-300" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M10 18a8 8 0 1 0 0-16 8 8 0 0 0 0 16Zm0-2a6 6 0 1 0 0-12 6 6 0 0 0 0 12Z" clip-rule="evenodd" /></svg>',
        size: :medium
      ))
    end
  end

  # Build options for rendering
  # @return [Array, Hash] Normalized options
  def normalized_options
    case @options
    when Array
      normalize_array_options(@options)
    when Hash
      @options.transform_values { |opts| normalize_array_options(opts) }
    else
      []
    end
  end

  # Normalize array options to [label, value] pairs
  # @param options [Array] The options array
  # @return [Array<Array>] Normalized [label, value] pairs
  def normalize_array_options(options)
    options.map do |option|
      if option.is_a?(Array)
        option # Already [label, value] format
      else
        [ option.to_s, option.to_s ] # Simple value, use as both label and value
      end
    end
  end

  def field_attributes
    attrs = {
      id: @id,
      required: @required || nil,
      disabled: @disabled || nil,
      "aria-invalid": has_error? ? "true" : nil,
      "aria-describedby": aria_describedby
    }.compact

    merge_html_attributes(attrs)
  end
end
