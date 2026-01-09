# frozen_string_literal: true

# Display::StatCardComponent
#
# A component for displaying statistics or key metrics with optional icon,
# label, and trend indicator. Designed for dashboard widgets.
#
# @example Simple stat
#   <%= render Display::StatCardComponent.new(
#     value: "€1,234",
#     label: "Pending Commissions"
#   ) %>
#
# @example With icon
#   <%= render Display::StatCardComponent.new(
#     icon_name: "currency-dollar",
#     value: "€1,234",
#     label: "Total Revenue"
#   ) %>
#
# @example With custom styling
#   <%= render Display::StatCardComponent.new(
#     icon_name: "users",
#     value: "42",
#     label: "Active Vendors",
#     value_color: :primary
#   ) %>
#
# @example Large variant
#   <%= render Display::StatCardComponent.new(
#     value: "€5,678",
#     label: "Total pending",
#     size: :large,
#     value_color: :warning
#   ) %>
#
class Display::StatCardComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available value color options
  VALUE_COLORS = {
    default: "text-slate-900",
    primary: "text-indigo-600",
    success: "text-green-600",
    warning: "text-amber-600",
    danger: "text-red-600",
    info: "text-sky-600"
  }.freeze

  # Size configurations
  SIZES = {
    medium: { value: "text-2xl", label: "text-sm" },
    large: { value: "text-4xl", label: "text-base" },
    xlarge: { value: "text-5xl", label: "text-lg" }
  }.freeze

  # @param value [String] The primary statistic value to display
  # @param label [String, Symbol] Label describing the statistic (String for literal text, Symbol for I18n key)
  # @param label_options [Hash] I18n interpolation options for label translation
  # @param icon_name [String, nil] Optional heroicon name
  # @param icon_color [Symbol] Icon color (default: :current)
  # @param value_color [Symbol] Color for the value text (:default, :primary, :success, :warning, :danger, :info)
  # @param size [Symbol] Size variant (:medium, :large, :xlarge)
  # @param centered [Boolean] Whether to center-align content
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    value:,
    label:,
    label_options: {},
    icon_name: nil,
    icon_color: :current,
    value_color: :default,
    size: :medium,
    centered: true,
    **html_attributes
  )
    @value = value
    @label = label
    @label_options = label_options
    @icon_name = icon_name
    @icon_color = icon_color
    @value_color = value_color
    @size = size
    @centered = centered
    @html_attributes = html_attributes

    validate_value_color!
    validate_size!
  end

  private

  def validate_value_color!
    return if VALUE_COLORS.key?(@value_color)

    raise ArgumentError, "Invalid value_color: #{@value_color}. Valid colors: #{VALUE_COLORS.keys.join(', ')}"
  end

  def validate_size!
    return if SIZES.key?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Valid sizes: #{SIZES.keys.join(', ')}"
  end

  def container_classes
    classes = [
      alignment_classes,
      @html_attributes[:class]
    ].compact

    classes.join(" ")
  end

  def alignment_classes
    @centered ? "text-center" : ""
  end

  def value_classes
    [
      SIZES[@size][:value],
      "font-bold",
      VALUE_COLORS[@value_color]
    ].join(" ")
  end

  def label_classes
    [
      SIZES[@size][:label],
      "text-slate-600 mt-2"
    ].join(" ")
  end

  def icon_container_classes
    @centered ? "flex justify-center mb-3" : "mb-3"
  end

  def merged_html_attributes
    @html_attributes.except(:class)
  end

  # Generate unique ID for label element (used by aria-labelledby)
  def label_id
    @label_id ||= "stat-label-#{object_id}"
  end

  # Extract numeric value for machine-readable data element
  # Removes currency symbols, commas, and non-numeric characters
  def numeric_value
    @value.to_s.gsub(/[^\d.-]/, "").presence
  end

  # Get label text with I18n support
  # Accepts Symbol for translation key or String for literal text
  def label_text
    if @label.is_a?(Symbol)
      t_component(@label.to_s, default: @label.to_s.humanize, **@label_options)
    else
      @label
    end
  end

  def show_icon?
    @icon_name.present?
  end
end
