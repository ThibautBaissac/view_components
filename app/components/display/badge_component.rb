# frozen_string_literal: true

# Display::BadgeComponent
#
# A flexible badge component for displaying status indicators, labels, or counts.
# Supports different variants (solid, subtle, outline) and colors with optional
# icons and dismissible functionality.
#
# @example Basic badge
#   <%= render Display::BadgeComponent.new(text: "New") %>
#
# @example With different colors
#   <%= render Display::BadgeComponent.new(text: "Active", color: :success) %>
#   <%= render Display::BadgeComponent.new(text: "Pending", color: :warning) %>
#   <%= render Display::BadgeComponent.new(text: "Inactive", color: :danger) %>
#
# @example With different variants
#   <%= render Display::BadgeComponent.new(text: "Solid", variant: :solid) %>
#   <%= render Display::BadgeComponent.new(text: "Subtle", variant: :subtle) %>
#   <%= render Display::BadgeComponent.new(text: "Outline", variant: :outline) %>
#
# @example With different sizes
#   <%= render Display::BadgeComponent.new(text: "Small", size: :small) %>
#   <%= render Display::BadgeComponent.new(text: "Medium", size: :medium) %>
#   <%= render Display::BadgeComponent.new(text: "Large", size: :large) %>
#
# @example With icon
#   <%= render Display::BadgeComponent.new(text: "Status") do |badge| %>
#     <% badge.with_icon(name: "check-circle", variant: :solid) %>
#   <% end %>
#
# @example Dismissible badge
#   <%= render Display::BadgeComponent.new(text: "Tag", dismissible: true) %>
#
# @example Pill shaped
#   <%= render Display::BadgeComponent.new(text: "Pill", pill: true) %>
#
# @see Display::BadgeComponentPreview Lookbook previews
class Display::BadgeComponent < ViewComponent::Base
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available variants
  VARIANTS = %i[solid subtle outline].freeze

  # Default variant
  DEFAULT_VARIANT = :subtle

  # Available colors
  COLORS = %i[neutral primary secondary success warning danger info].freeze

  # Default color
  DEFAULT_COLOR = :neutral

  # Available sizes
  SIZES = %i[small medium large].freeze

  # Default size
  DEFAULT_SIZE = :small

  # Color configurations per variant
  COLOR_CONFIG = {
    solid: {
      neutral: "bg-slate-600 text-white shadow-sm",
      primary: "bg-indigo-600 text-white shadow-sm shadow-indigo-500/20",
      secondary: "bg-slate-500 text-white shadow-sm",
      success: "bg-green-600 text-white shadow-sm shadow-green-500/20",
      warning: "bg-yellow-600 text-white shadow-sm shadow-yellow-600/20",
      danger: "bg-red-600 text-white shadow-sm shadow-red-500/20",
      info: "bg-sky-500 text-white shadow-sm shadow-sky-500/20"
    },
    subtle: {
      neutral: "bg-slate-100 text-slate-800 border border-slate-200",
      primary: "bg-indigo-50 text-indigo-700 border border-indigo-200",
      secondary: "bg-slate-50 text-slate-700 border border-slate-200",
      success: "bg-green-50 text-green-700 border border-green-200",
      warning: "bg-yellow-50 text-yellow-800 border border-yellow-200",
      danger: "bg-red-50 text-red-700 border border-red-200",
      info: "bg-sky-50 text-sky-700 border border-sky-200"
    },
    outline: {
      neutral: "border-2 border-slate-300 text-slate-700 bg-white",
      primary: "border-2 border-indigo-500 text-indigo-700 bg-white",
      secondary: "border-2 border-slate-400 text-slate-700 bg-white",
      success: "border-2 border-green-500 text-green-700 bg-white",
      warning: "border-2 border-yellow-500 text-yellow-800 bg-white",
      danger: "border-2 border-red-500 text-red-700 bg-white",
      info: "border-2 border-sky-500 text-sky-700 bg-white"
    }
  }.freeze

  # Size configurations
  SIZE_CONFIG = {
    small: "px-2.5 py-0.5 text-xs",
    medium: "px-3 py-1 text-sm",
    large: "px-3.5 py-1.5 text-base"
  }.freeze

  # Icon size mapping
  ICON_SIZE_MAP = {
    small: :xs,
    medium: :small,
    large: :medium
  }.freeze

  # Slots
  renders_one :icon, ->(name:, variant: nil, **options) do
    # Adapt icon variant to badge variant if not explicitly provided
    icon_variant = variant || (@variant == :outline ? :outline : :solid)
    Foundation::IconComponent.new(
      name: name,
      variant: icon_variant,
      size: ICON_SIZE_MAP[@size],
      **options
    )
  end

  # @param text [String] The badge text content (optional if using block)
  # @param variant [Symbol] The badge variant (:solid, :subtle, :outline)
  # @param color [Symbol] The badge color (:neutral, :primary, :secondary, :success, :warning, :danger, :info)
  # @param size [Symbol] The badge size (:small, :medium, :large)
  # @param pill [Boolean] Whether to use pill shape (fully rounded)
  # @param dismissible [Boolean] Whether the badge can be dismissed
  # @param dismiss_label [String] Custom aria-label for dismiss button (defaults to French translation)
  # @param role [String] Optional ARIA role (e.g., "status" for dynamic status badges)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    text: nil,
    variant: DEFAULT_VARIANT,
    color: DEFAULT_COLOR,
    size: DEFAULT_SIZE,
    pill: false,
    dismissible: false,
    dismiss_label: nil,
    role: nil,
    **html_attributes
  )
    @text = text
    @variant = variant.to_sym
    @color = color.to_sym
    @size = size.to_sym
    @pill = pill
    @dismissible = dismissible
    @dismiss_label = dismiss_label
    @role = role
    @html_attributes = html_attributes

    validate_variant!
    validate_color!
    validate_size!
  end

  # Check if badge should render
  # @return [Boolean]
  def render?
    @text.present? || content?
  end

  private

  def validate_variant!
    return if VARIANTS.include?(@variant)

    raise ArgumentError, "Invalid variant: #{@variant}. Must be one of #{VARIANTS.join(', ')}"
  end

  def validate_color!
    return if COLORS.include?(@color)

    raise ArgumentError, "Invalid color: #{@color}. Must be one of #{COLORS.join(', ')}"
  end

  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Must be one of #{SIZES.join(', ')}"
  end

  def badge_classes
    classes = [
      "badge",
      "inline-flex items-center gap-1.5 font-semibold",
      SIZE_CONFIG[@size],
      COLOR_CONFIG[@variant][@color],
      border_radius_classes
    ]

    classes.compact.join(" ")
  end

  def border_radius_classes
    @pill ? "rounded-full" : "rounded-md"
  end

  def dismiss_button_classes
    "ml-0.5 -mr-1 inline-flex items-center justify-center hover:opacity-75 focus:outline-none focus:ring-1 focus:ring-current rounded"
  end

  def controller_data
    return {} unless @dismissible

    { data: { controller: "components--badge" } }
  end

  def merged_html_attributes
    default_attrs = controller_data
    default_attrs[:role] = @role if @role.present?
    attrs = @html_attributes.except(:class)
    default_attrs.deep_merge(attrs)
  end

  def dismiss_button_aria_label
    @dismiss_label || t_component("dismiss", default: "Remove badge")
  end

  def computed_classes
    custom_class = @html_attributes[:class]
    [ badge_classes, custom_class ].compact.join(" ")
  end

  def dismiss_icon_size
    ICON_SIZE_MAP[@size]
  end

  def badge_text
    @text || content
  end
end
