# frozen_string_literal: true

# Form::Field::CheckboxGroupComponent
#
# A checkbox group component that renders multiple checkboxes with consistent styling,
# labels, hints, error handling, and accessibility features. Uses composition to render
# individual CheckboxComponent instances, avoiding code duplication.
#
# Note: Custom HTML attributes support nested hashes for data attributes:
#   data: { controller: "my-controller", action: "click->my#handle" }
# Will be flattened and rendered as:
#   data-controller="my-controller" data-action="click->my#handle"
#
# @example Basic usage with simple array
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "interests[]",
#     options: ["Reading", "Sports", "Music"]
#   ) %>
#
# @example With group label
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "interests[]",
#     label: "What are your interests?",
#     options: ["Reading", "Sports", "Music", "Travel"]
#   ) %>
#
# @example With label-value pairs
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "notifications[]",
#     label: "Notification Preferences",
#     options: [
#       ["Email notifications", "email"],
#       ["SMS notifications", "sms"],
#       ["Push notifications", "push"]
#     ]
#   ) %>
#
# @example With pre-selected values
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "features[]",
#     label: "Enabled Features",
#     options: [["API Access", "api"], ["Dashboard", "dashboard"], ["Reports", "reports"]],
#     value: ["api", "dashboard"]
#   ) %>
#
# @example With hint
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "terms[]",
#     label: "Legal Agreements",
#     options: [
#       ["Terms of Service", "tos"],
#       ["Privacy Policy", "privacy"],
#       ["Cookie Policy", "cookies"]
#     ],
#     hint: "You must accept all required agreements to continue."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "categories[]",
#     label: "Categories",
#     options: ["Tech", "Sports", "Music"],
#     error: "must select at least one category"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "agreements[]",
#     label: "Required Agreements",
#     options: [["Terms of Service", "tos"], ["Privacy Policy", "privacy"]],
#     required: true
#   ) %>
#
# @example With inline layout
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "days[]",
#     label: "Available Days",
#     options: ["Mon", "Tue", "Wed", "Thu", "Fri"],
#     layout: :inline
#   ) %>
#
# @example With custom size
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "options[]",
#     label: "Options",
#     options: ["Option 1", "Option 2", "Option 3"],
#     size: :large
#   ) %>
#
# @example Disabled checkboxes
#   <%= render Form::Field::CheckboxGroupComponent.new(
#     name: "locked[]",
#     label: "Locked Options",
#     options: ["Option 1", "Option 2"],
#     value: ["Option 1"],
#     disabled: true
#   ) %>
#
class Form::Field::CheckboxGroupComponent < Form::Field::BaseComponent
  # Available layout options
  LAYOUTS = %i[stacked inline].freeze

  # Default layout
  DEFAULT_LAYOUT = :stacked

  # @param name [String] The field name attribute (required, should typically end with [])
  # @param options [Array] The checkbox options (simple array or label-value pairs)
  # @param id [String] The fieldset id attribute (defaults to sanitized name)
  # @param value [Array, String] The selected value(s)
  # @param label [String] The legend text for the fieldset
  # @param hint [String] Help text displayed below the group
  # @param error [String, Array<String>] Error message(s) for the group
  # @param required [Boolean] Whether at least one checkbox is required
  # @param disabled [Boolean] Whether all checkboxes are disabled
  # @param size [Symbol] The checkbox size (:small, :medium, :large)
  # @param layout [Symbol] The layout style (:stacked, :inline)
  # @param include_hidden [Boolean] Whether to include hidden field for each checkbox
  # @param html_attributes [Hash] Additional HTML attributes for the fieldset
  def initialize(
    name:,
    options: [],
    layout: DEFAULT_LAYOUT,
    include_hidden: false,
    **base_options
  )
    super(name: name, **base_options)
    @options = options
    @layout = layout.to_sym
    @include_hidden = include_hidden
    @value = Array(@value).map(&:to_s) # Ensure value is always an array of strings

    validate_layout!
  end

  # Get normalized options as [label, value] pairs
  # @return [Array<Array>]
  def normalized_options
    @normalized_options ||= @options.map do |option|
      case option
      when Array
        # Already [label, value] format
        [ option[0].to_s, option[1].to_s ]
      else
        # Simple string/value, use as both label and value
        [ option.to_s, option.to_s ]
      end
    end
  end

  # Check if a specific value is selected
  # @param value [String] The value to check
  # @return [Boolean]
  def selected?(value)
    @value.include?(value.to_s)
  end

  # Generate unique ID for a checkbox option
  # @param index [Integer] The option index
  # @return [String]
  def checkbox_id(index)
    "#{@id}_#{index}"
  end

  # Whether the group uses inline layout
  # @return [Boolean]
  def inline_layout?
    @layout == :inline
  end

  # Whether the group uses stacked layout
  # @return [Boolean]
  def stacked_layout?
    @layout == :stacked
  end

  private

  # Validate the layout parameter
  # @raise [ArgumentError] if layout is invalid
  def validate_layout!
    return if LAYOUTS.include?(@layout)

    raise ArgumentError, "Invalid layout: #{@layout}. Valid layouts are: #{LAYOUTS.join(', ')}"
  end

  # CSS classes for the fieldset wrapper
  # @return [String]
  def wrapper_classes
    classes = [ "form-field" ]
    classes << @html_attributes[:class] if @html_attributes[:class].present?
    classes.join(" ")
  end

  # CSS classes for the legend (group label)
  # @return [String]
  def legend_classes
    classes = [ "block font-semibold text-slate-700 mb-2" ]
    classes << size_label_classes
    classes.join(" ")
  end

  # CSS classes for the checkboxes container
  # @return [String]
  def checkboxes_container_classes
    if inline_layout?
      "flex flex-wrap gap-4"
    else
      "space-y-3"
    end
  end

  # Flatten HTML attributes for fieldset, excluding class which is handled separately
  # @return [String] Flattened HTML attributes string
  def fieldset_html_attributes
    return "" if @html_attributes.empty?

    attrs_without_class = @html_attributes.except(:class)
    return "" if attrs_without_class.empty?

    flatten_attributes(attrs_without_class).map do |k, v|
      %(#{ERB::Util.html_escape(k.to_s)}="#{ERB::Util.html_escape(v.to_s)}")
    end.join(" ").html_safe
  end

  # Render a checkbox option with optional inline wrapper
  # @param label [String] The checkbox label
  # @param value [String] The checkbox value
  # @param index [Integer] The option index
  # @return [String] Rendered checkbox HTML
  def render_checkbox_option(label, value, index)
    checkbox_html = render(Form::Field::CheckboxComponent.new(
      name: @name,
      id: checkbox_id(index),
      value: value,
      label: label,
      checked: selected?(value),
      required: false,
      disabled: @disabled,
      size: @size,
      include_hidden: @include_hidden
    ))

    if inline_layout?
      tag.div(checkbox_html, class: "flex-shrink-0")
    else
      checkbox_html
    end
  end
end
