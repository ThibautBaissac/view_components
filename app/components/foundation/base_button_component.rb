# frozen_string_literal: true

# Abstract base component for button-like elements (buttons and links).
#
# Provides shared styling, variants, sizes, and accessibility features for both
# ButtonComponent and LinkComponent. This component should not be rendered directly;
# instead, use its subclasses.
#
# @abstract Subclass and override {#merged_html_attributes} to add element-specific attributes
#
# @example Rendering a primary button (via ButtonComponent)
#   <%= render Foundation::ButtonComponent.new(text: "Save", variant: :primary) %>
#
# @example Rendering a link styled as a button (via LinkComponent)
#   <%= render Foundation::LinkComponent.new(text: "View", href: "/items", variant: :secondary) %>
#
# @example With leading icon
#   <%= render Foundation::ButtonComponent.new(text: "Delete", variant: :danger) do |c| %>
#     <% c.with_icon_leading do %>
#       <svg>...</svg>
#     <% end %>
#   <% end %>
#
# @param text [String, nil] Button/link text content
# @param variant [Symbol] Visual style variant (:primary, :secondary, :success, :danger, :warning, :outline, :ghost, :link)
# @param resource_color [Symbol, nil] Optional resource color (:amber, :rose, :emerald) - overrides variant color
# @param size [Symbol] Size variant (:small, :medium, :large)
# @param disabled [Boolean] Whether the element is disabled
# @param full_width [Boolean] Whether the element should span full width
# @param html_attributes [Hash] Additional HTML attributes (class, id, data, aria, etc.)
#
# @note Validates accessible name in development mode when text is not provided
# @note Adds pointer-events-none to disabled elements to prevent keyboard/mouse interaction
#
# @see Foundation::ButtonComponent
# @see Foundation::LinkComponent
class Foundation::BaseButtonComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Slots for flexible content
  renders_one :icon_leading
  renders_one :icon_trailing

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  VARIANTS = %i[primary secondary success danger warning outline ghost link].freeze
  SIZES = %i[small medium large].freeze

  # Common focus ring classes for consistency
  FOCUS_RING_CLASSES = "focus:outline-none focus:ring-2 focus:ring-offset-2 focus-visible:ring-2".freeze

  def initialize(
    text: nil,
    variant: :primary,
    resource_color: nil,
    size: :medium,
    disabled: false,
    full_width: false,
    **html_attributes
  )
    @text = text
    @variant = variant
    @resource_color = resource_color
    @size = size
    @disabled = disabled
    @full_width = full_width
    @html_attributes = html_attributes

    validate_variant!
    validate_size!
  end

  private

  def element_classes
    [
      base_classes,
      variant_classes,
      size_classes,
      width_class,
      disabled_classes,
      @html_attributes[:class]
    ].compact.join(" ")
  end

  def base_classes
    "inline-flex items-center justify-center gap-2 font-semibold transition-all duration-200 #{FOCUS_RING_CLASSES}"
  end

  def disabled_classes
    "opacity-60 cursor-not-allowed saturate-50 pointer-events-none" if disabled?
  end

  def variant_classes
    # If resource_color is provided, use resource-specific styles
    return resource_color_classes if @resource_color.present?

    case @variant
    when :primary
      "bg-indigo-600 hover:bg-indigo-700 text-white active:scale-95 shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:shadow-indigo-500/40 focus:ring-indigo-500"
    when :secondary
      "bg-slate-600 text-white hover:bg-slate-700 active:scale-95 shadow-lg shadow-slate-500/30 hover:shadow-xl hover:shadow-slate-500/40 focus:ring-slate-500"
    when :success
      "bg-green-600 hover:bg-green-700 text-white active:scale-95 shadow-lg shadow-green-500/30 hover:shadow-xl hover:shadow-green-500/40 focus:ring-green-500"
    when :danger
      "bg-red-600 hover:bg-red-700 text-white active:scale-95 shadow-lg shadow-red-500/30 hover:shadow-xl hover:shadow-red-500/40 focus:ring-red-500"
    when :warning
      "bg-yellow-700 hover:bg-yellow-800 text-white active:scale-95 shadow-lg shadow-yellow-700/30 hover:shadow-xl hover:shadow-yellow-700/40 focus:ring-yellow-700"
    when :outline
      "border-2 border-indigo-600 text-indigo-700 hover:bg-indigo-50 hover:border-indigo-700 active:scale-95 focus:ring-indigo-500"
    when :ghost
      "text-slate-700 hover:bg-slate-100/80 hover:text-slate-900 active:scale-95 focus:ring-slate-500"
    when :link
      "text-indigo-600 hover:underline focus:ring-indigo-500"
    else
      "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500"
    end
  end

  def resource_color_classes
    # If variant is outline, use outline style with resource color
    if @variant == :outline
      case @resource_color
      when :amber
        "border-2 border-amber-600 text-amber-700 bg-white hover:bg-amber-50 hover:border-amber-700 active:scale-95 focus:ring-amber-500"
      when :rose
        "border-2 border-rose-600 text-rose-700 bg-white hover:bg-rose-50 hover:border-rose-700 active:scale-95 focus:ring-rose-500"
      when :emerald
        "border-2 border-emerald-600 text-emerald-700 bg-white hover:bg-emerald-50 hover:border-emerald-700 active:scale-95 focus:ring-emerald-500"
      end
    else
      # Default solid style with resource color
      case @resource_color
      when :amber
        "bg-amber-600 hover:bg-amber-700 text-white active:scale-95 shadow-lg shadow-amber-500/30 hover:shadow-xl hover:shadow-amber-500/40 focus:ring-amber-500"
      when :rose
        "bg-rose-600 hover:bg-rose-700 text-white active:scale-95 shadow-lg shadow-rose-500/30 hover:shadow-xl hover:shadow-rose-500/40 focus:ring-rose-500"
      when :emerald
        "bg-emerald-600 hover:bg-emerald-700 text-white active:scale-95 shadow-lg shadow-emerald-500/30 hover:shadow-xl hover:shadow-emerald-500/40 focus:ring-emerald-500"
      end
    end
  end

  def size_classes
    case @size
    when :small
      "px-3 py-2 text-sm rounded-lg"
    when :medium
      "px-5 py-2.5 text-base rounded-lg"
    when :large
      "px-6 py-3 text-lg rounded-xl"
    else
      "px-5 py-2.5 text-base rounded-lg"
    end
  end

  def width_class
    "w-full" if @full_width
  end

  # Override in subclasses to add element-specific attributes
  def merged_html_attributes
    @html_attributes
  end

  # Override attributes_for_rendering to use merged attributes
  def attributes_for_rendering
    merged_html_attributes
  end

  def disabled?
    @disabled
  end

  def validate_accessible_name!
    return if @text.present?
    return if @html_attributes[:aria]&.dig(:label)
    return if @html_attributes[:aria]&.dig(:labelledby)
    return if @html_attributes[:"aria-label"]
    return if @html_attributes[:"aria-labelledby"]
    return if @html_attributes[:title]

    Rails.logger.warn(
      "#{self.class.name}: Missing accessible name. " \
      "Provide text, aria-label, aria-labelledby, or title for icon-only elements."
    ) if Rails.env.development?
  end

  def validate_variant!
    return if VARIANTS.include?(@variant)

    raise ArgumentError, "Invalid variant: #{@variant}. Valid variants are: #{VARIANTS.join(', ')}"
  end

  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Valid sizes are: #{SIZES.join(', ')}"
  end
end
