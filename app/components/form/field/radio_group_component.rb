# frozen_string_literal: true

# Form::Field::RadioGroupComponent
#
# A radio group component that renders multiple radio buttons with consistent styling,
# labels, hints, error handling, and accessibility features. Uses composition to render
# individual RadioComponent instances, avoiding code duplication.
#
# Radio groups provide mutual exclusivity - only one option can be selected at a time.
# The component automatically wraps radios in a <fieldset> with <legend> for proper
# accessibility and screen reader support.
#
# Note: Custom HTML attributes support nested hashes for data attributes:
#   data: { controller: "my-controller", action: "click->my#handle" }
# Will be flattened and rendered as:
#   data-controller="my-controller" data-action="click->my#handle"
#
# Keyboard Navigation (native HTML behavior):
# - Tab: Move focus to/from the radio group
# - Arrow Keys (↑/↓/←/→): Navigate between radio options and automatically select
# - Space: Select the focused radio option (if not already selected)
# - The first radio (or checked radio) receives focus when tabbing into the group
#
# @example Basic usage with simple array
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "plan",
#     options: ["Basic", "Pro", "Enterprise"]
#   ) %>
#
# @example With group label
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "subscription",
#     label: "Choose your subscription plan",
#     options: ["Free", "Pro", "Enterprise"]
#   ) %>
#
# @example With label-value pairs
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "billing_cycle",
#     label: "Billing Cycle",
#     options: [
#       ["Monthly - $29/month", "monthly"],
#       ["Annual - $278/year (Save 20%)", "annual"],
#       ["Lifetime - $499 one-time", "lifetime"]
#     ]
#   ) %>
#
# @example With pre-selected value
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "theme",
#     label: "Theme Preference",
#     options: [["Light", "light"], ["Dark", "dark"], ["Auto", "auto"]],
#     value: "dark"
#   ) %>
#
# @example With hint
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "payment_method",
#     label: "Payment Method",
#     options: [
#       ["Credit Card", "card"],
#       ["PayPal", "paypal"],
#       ["Bank Transfer", "bank"]
#     ],
#     hint: "You can change your payment method later in account settings."
#   ) %>
#
# @example With error state
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "plan",
#     label: "Select a plan",
#     options: ["Basic", "Pro", "Enterprise"],
#     error: "Please select a plan to continue"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "terms_acceptance",
#     label: "Do you accept the terms?",
#     options: [["Yes, I accept", "yes"], ["No, I decline", "no"]],
#     required: true
#   ) %>
#
# @example With inline layout
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "size",
#     label: "Select Size",
#     options: ["Small", "Medium", "Large", "XL"],
#     layout: :inline
#   ) %>
#
# @example With custom size
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "priority",
#     label: "Priority Level",
#     options: ["Low", "Medium", "High", "Critical"],
#     size: :large
#   ) %>
#
# @example Disabled radios
#   <%= render Form::Field::RadioGroupComponent.new(
#     name: "locked_option",
#     label: "Plan (Locked)",
#     options: ["Legacy Plan", "Current Plan"],
#     value: "Legacy Plan",
#     disabled: true
#   ) %>
#
class Form::Field::RadioGroupComponent < Form::Field::BaseComponent
  # Available layout options
  LAYOUTS = %i[stacked inline].freeze

  # Default layout
  DEFAULT_LAYOUT = :stacked

  # @param name [String] The field name attribute (required)
  # @param options [Array] The radio options (simple array or label-value pairs)
  # @param id [String] The fieldset id attribute (defaults to sanitized name)
  # @param value [String] The selected value
  # @param label [String] The legend text for the fieldset
  # @param hint [String] Help text displayed below the group
  # @param error [String, Array<String>] Error message(s) for the group
  # @param required [Boolean] Whether a selection is required
  # @param disabled [Boolean] Whether all radios are disabled
  # @param size [Symbol] The radio size (:small, :medium, :large)
  # @param layout [Symbol] The layout style (:stacked, :inline)
  # @param html_attributes [Hash] Additional HTML attributes for the fieldset
  def initialize(
    name:,
    options: [],
    layout: DEFAULT_LAYOUT,
    **base_options
  )
    super(name: name, **base_options)
    @options = options
    @layout = layout.to_sym
    @value = @value.to_s if @value # Ensure value is a string for comparison

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
    @value.to_s == value.to_s
  end

  # Generate unique ID for a radio option
  # @param index [Integer] The option index
  # @return [String]
  def radio_id(index)
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
    "form-field"
  end

  # CSS classes for the legend (group label)
  # @return [String]
  def legend_classes
    classes = [ "block font-medium text-slate-700 mb-2" ]
    classes << size_label_classes
    classes.join(" ")
  end

  # CSS classes for the radios container
  # @return [String]
  def radios_container_classes
    if inline_layout?
      "flex flex-wrap gap-4"
    else
      "space-y-3"
    end
  end

  # Render a radio option with optional inline wrapper
  # @param label [String] The radio label
  # @param value [String] The radio value
  # @param index [Integer] The option index
  # @return [String] Rendered radio HTML
  def render_radio_option(label, value, index)
    radio_html = render(Form::Field::RadioComponent.new(
      name: @name,
      id: radio_id(index),
      value: value,
      label: label,
      checked: selected?(value),
      required: @required,
      disabled: @disabled,
      size: @size
    ))

    if inline_layout?
      tag.div(radio_html, class: "flex-shrink-0")
    else
      radio_html
    end
  end
end
