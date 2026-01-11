# frozen_string_literal: true

# Form::Field::SelectComponent
#
# A flexible select component that wraps a standard HTML select element
# with consistent styling, labels, hints, and error handling.
#
# @example Basic usage with options array
#   <%= render Form::Field::SelectComponent.new(
#     name: "country",
#     options: ["USA", "Canada", "Mexico"]
#   ) %>
#
# @example With label-value pairs
#   <%= render Form::Field::SelectComponent.new(
#     name: "country",
#     options: [["United States", "us"], ["Canada", "ca"], ["Mexico", "mx"]]
#   ) %>
#
# @example With grouped options
#   <%= render Form::Field::SelectComponent.new(
#     name: "city",
#     options: {
#       "North America" => [["New York", "ny"], ["Toronto", "to"]],
#       "Europe" => [["London", "lo"], ["Paris", "pa"]]
#     }
#   ) %>
#
# @example With prompt
#   <%= render Form::Field::SelectComponent.new(
#     name: "status",
#     label: "Status",
#     options: ["Active", "Inactive"],
#     prompt: "Select a status"
#   ) %>
#
# @example With include_blank
#   <%= render Form::Field::SelectComponent.new(
#     name: "category",
#     label: "Category",
#     options: ["Tech", "Sports", "Music"],
#     include_blank: true
#   ) %>
#
# @example With custom blank option text
#   <%= render Form::Field::SelectComponent.new(
#     name: "category",
#     label: "Category",
#     options: ["Tech", "Sports"],
#     include_blank: "-- None --"
#   ) %>
#
# @example With selected value
#   <%= render Form::Field::SelectComponent.new(
#     name: "status",
#     options: ["Active", "Inactive"],
#     value: "Active"
#   ) %>
#
# @example With error state
#   <%= render Form::Field::SelectComponent.new(
#     name: "category",
#     label: "Category",
#     options: ["Tech", "Sports"],
#     error: "must be selected"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::SelectComponent.new(
#     name: "priority",
#     label: "Priority",
#     options: ["Low", "Medium", "High"],
#     required: true
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::SelectComponent.new(
#     name: "locked_status",
#     options: ["Locked"],
#     value: "Locked",
#     disabled: true
#   ) %>
#
# @example With French localization
#   <%= render Form::Field::SelectComponent.new(
#     name: "type_prestataire",
#     label: "Type de prestataire",
#     options: [["DJ", "dj"], ["Photographe", "photographer"]],
#     prompt: t("components.form.field.select.prompt")
#   ) %>
#
class Form::Field::SelectComponent < Form::Field::BaseComponent
  # @param name [String] The select name attribute (required)
  # @param options [Array, Hash] The select options (simple array, label-value pairs, or grouped options hash)
  # @param id [String] The select id attribute (defaults to name)
  # @param value [String] The selected value
  # @param label [String] The label text
  # @param prompt [String] Placeholder prompt option (disabled, not selectable)
  # @param include_blank [Boolean, String] Whether to include a blank option (true for empty, string for custom text)
  # @param hint [String] Help text displayed below the select
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param size [Symbol] The select size (:small, :medium, :large)
  # @param html_attributes [Hash] Additional HTML attributes for the select
  def initialize(
    name:,
    options: [],
    prompt: nil,
    include_blank: false,
    **base_options
  )
    super(name: name, **base_options)
    @options = options
    @prompt = prompt
    @include_blank = include_blank
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
    return false if @value.nil?

    @value.to_s == option_value.to_s
  end

  private

  def select_classes
    classes = [
      base_field_classes,
      size_field_classes,
      state_field_classes,
      "appearance-none bg-no-repeat bg-right cursor-pointer"
    ]
    classes << select_icon_padding
    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  # Right padding for the dropdown arrow icon
  def select_icon_padding
    case @size
    when :small
      "pr-8"
    when :medium
      "pr-10"
    when :large
      "pr-12"
    end
  end

  def select_attributes
    attrs = base_field_attributes
    merge_html_attributes(attrs)
  end

  def merged_select_attributes
    select_attributes.merge(class: select_classes)
  end

  # Build options for the select element
  # @return [Array] Normalized options array
  def normalized_options
    case @options
    when Array
      normalize_array_options(@options)
    when Hash
      @options # Return as-is for grouped rendering
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

  # Icon wrapper classes for the dropdown arrow
  def icon_wrapper_classes
    base = "pointer-events-none absolute inset-y-0 right-0 flex items-center"
    padding = case @size
    when :small
      "pr-2"
    when :medium
      "pr-3"
    when :large
      "pr-4"
    end
    "#{base} #{padding}"
  end

  # Icon color based on state
  def icon_color_classes
    if has_error?
      "text-red-400"
    elsif @disabled
      "text-slate-300"
    else
      "text-slate-400"
    end
  end

  # Icon size based on field size
  def icon_size
    case @size
    when :small
      :small
    when :medium
      :medium
    when :large
      :large
    end
  end
end
