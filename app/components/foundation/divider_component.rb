# frozen_string_literal: true

# Flexible divider component for visually separating content.
#
# Supports horizontal and vertical orientations with customizable styling,
# thickness options, color variants, spacing control, and optional label text.
# Automatically applies appropriate semantic HTML and ARIA attributes for
# accessibility. Uses <hr> element for horizontal decorative dividers and
# <div> for vertical or labeled dividers.
#
# @example Basic horizontal divider (uses semantic <hr> element)
#   <%= render Foundation::DividerComponent.new %>
#
# @example Vertical divider with custom height
#   <%= render Foundation::DividerComponent.new(orientation: :vertical) %>
#
# @example Thick divider with primary color
#   <%= render Foundation::DividerComponent.new(thickness: :thick, color: :primary) %>
#
# @example Divider with label (uses <div> with role="separator")
#   <%= render Foundation::DividerComponent.new do %>
#     OR
#   <% end %>
#
# @example Divider with custom spacing
#   <%= render Foundation::DividerComponent.new(spacing: :large) %>
#
# @example Vertical divider in toolbar
#   <%= render Foundation::DividerComponent.new(
#     orientation: :vertical,
#     spacing: :small,
#     thickness: :thin,
#     color: :muted
#   ) %>
#
# @example Section divider with danger styling
#   <%= render Foundation::DividerComponent.new(
#     thickness: :medium,
#     color: :danger,
#     spacing: :xlarge
#   ) %>
#
# @param orientation [Symbol] Divider orientation (:horizontal, :vertical) (default: :horizontal)
# @param thickness [Symbol] Border thickness (:hairline, :thin, :medium, :thick) (default: :hairline)
# @param color [Symbol] Color variant (:default, :muted, :primary, :secondary, :success, :warning, :danger) (default: :default)
# @param spacing [Symbol] Margin spacing (:none, :small, :medium, :large, :xlarge) (default: :medium)
# @param html_attributes [Hash] Additional HTML attributes (class, id, data, aria, etc.)
#
# @note Decorative dividers (without label) include role="presentation" and aria-hidden="true"
# @note Semantic dividers (with label) include role="separator" and aria-orientation
# @note Horizontal decorative dividers use semantic <hr> element for better accessibility
# @note Vertical dividers and labeled dividers use <div> element with appropriate ARIA attributes
# @note All color variants meet WCAG 2.1 AA contrast requirements
#
class Foundation::DividerComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Orientation options
  ORIENTATIONS = %i[horizontal vertical].freeze

  # Thickness options
  THICKNESSES = {
    hairline: "border-t",
    thin: "border-t-2",
    medium: "border-t-4",
    thick: "border-t-8"
  }.freeze

  # Vertical thickness options
  VERTICAL_THICKNESSES = {
    hairline: "border-l",
    thin: "border-l-2",
    medium: "border-l-4",
    thick: "border-l-8"
  }.freeze

  # Color options
  COLORS = {
    default: "border-slate-300",
    muted: "border-slate-200",
    primary: "border-indigo-500",
    secondary: "border-slate-400",
    success: "border-green-500",
    warning: "border-yellow-500",
    danger: "border-red-500"
  }.freeze

  # Spacing options (margin)
  SPACINGS = {
    none: "my-0",
    small: "my-2",
    medium: "my-4",
    large: "my-6",
    xlarge: "my-8"
  }.freeze

  # Vertical spacing options
  VERTICAL_SPACINGS = {
    none: "mx-0",
    small: "mx-2",
    medium: "mx-4",
    large: "mx-6",
    xlarge: "mx-8"
  }.freeze

  # Default values
  DEFAULT_ORIENTATION = :horizontal
  DEFAULT_THICKNESS = :hairline
  DEFAULT_COLOR = :default
  DEFAULT_SPACING = :medium

  # @param orientation [Symbol] The orientation (:horizontal, :vertical)
  # @param thickness [Symbol] The border thickness (:hairline, :thin, :medium, :thick)
  # @param color [Symbol] The divider color (:default, :muted, :primary, :secondary, :success, :warning, :danger)
  # @param spacing [Symbol] The spacing around the divider (:none, :small, :medium, :large, :xlarge)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    orientation: DEFAULT_ORIENTATION,
    thickness: DEFAULT_THICKNESS,
    color: DEFAULT_COLOR,
    spacing: DEFAULT_SPACING,
    **html_attributes
  )
    @orientation = orientation
    @thickness = thickness
    @color = color
    @spacing = spacing
    @html_attributes = html_attributes

    validate_parameters!
  end

  # Check if divider has label content
  def has_label?
    content.present?
  end

  private

  def validate_parameters!
    unless ORIENTATIONS.include?(@orientation)
      raise ArgumentError, "Invalid orientation: #{@orientation}. Must be one of: #{ORIENTATIONS.join(', ')}"
    end

    unless THICKNESSES.key?(@thickness)
      raise ArgumentError, "Invalid thickness: #{@thickness}. Must be one of: #{THICKNESSES.keys.join(', ')}"
    end

    unless COLORS.key?(@color)
      raise ArgumentError, "Invalid color: #{@color}. Must be one of: #{COLORS.keys.join(', ')}"
    end

    unless SPACINGS.key?(@spacing)
      raise ArgumentError, "Invalid spacing: #{@spacing}. Must be one of: #{SPACINGS.keys.join(', ')}"
    end
  end

  def divider_classes
    classes = []

    if horizontal?
      classes << "w-full"
      classes << thickness_class
      classes << SPACINGS[@spacing]
    else
      classes << "h-full"
      classes << vertical_thickness_class
      classes << VERTICAL_SPACINGS[@spacing]
    end

    classes << COLORS[@color]

    classes.join(" ")
  end

  def container_classes
    return nil unless has_label?

    if horizontal?
      "flex items-center #{SPACINGS[@spacing]}"
    else
      "flex flex-col items-center #{VERTICAL_SPACINGS[@spacing]}"
    end
  end

  def label_classes
    if horizontal?
      "px-3 text-sm font-medium text-slate-600 whitespace-nowrap"
    else
      "py-3 text-sm font-medium text-slate-600 whitespace-nowrap"
    end
  end

  def line_classes
    classes = [ "flex-grow" ]

    if horizontal?
      classes << thickness_class
    else
      classes << vertical_thickness_class
      classes << "w-full"
    end

    classes << COLORS[@color]

    classes.join(" ")
  end

  def thickness_class
    THICKNESSES[@thickness]
  end

  def vertical_thickness_class
    VERTICAL_THICKNESSES[@thickness]
  end

  def horizontal?
    @orientation == :horizontal
  end

  def vertical?
    @orientation == :vertical
  end

  def attributes_for_rendering
    attrs = @html_attributes.dup

    if has_label?
      # Semantic separator with content
      attrs[:role] ||= "separator"
      attrs[:"aria-orientation"] = @orientation.to_s
    else
      # Decorative divider without content
      attrs[:role] = "presentation"
      attrs[:"aria-hidden"] = "true"
    end

    attrs
  end

  # Merged attributes for container (with label)
  def merged_html_attributes_with_container
    attrs = attributes_for_rendering
    # Merge custom class with computed container classes
    custom_class = attrs.delete(:class)
    combined_class = [ container_classes, custom_class ].compact.join(" ")
    attrs.merge(class: combined_class)
  end

  # Merged attributes for divider element (without label)
  def merged_html_attributes_with_divider
    attrs = attributes_for_rendering
    # Merge custom class with computed divider classes
    custom_class = attrs.delete(:class)
    combined_class = [ divider_classes, custom_class ].compact.join(" ")
    attrs.merge(class: combined_class)
  end
end
