# frozen_string_literal: true

# Foundation::SpinnerComponent
#
# A loading spinner component that displays a rotating animation to indicate
# ongoing activity. Includes proper ARIA attributes for accessibility.
#
# @example Basic spinner
#   <%= render Foundation::SpinnerComponent.new %>
#
# @example With label
#   <%= render Foundation::SpinnerComponent.new(label: "Chargement...") %>
#
# @example Different sizes
#   <%= render Foundation::SpinnerComponent.new(size: :small) %>
#   <%= render Foundation::SpinnerComponent.new(size: :large) %>
#
# @example Different colors
#   <%= render Foundation::SpinnerComponent.new(color: :primary) %>
#   <%= render Foundation::SpinnerComponent.new(color: :white) %>
#
# @example Centered
#   <%= render Foundation::SpinnerComponent.new(centered: true, label: "Chargement des données...") %>
#
# @example Inline with text
#   <%= render Foundation::SpinnerComponent.new(size: :small, inline: true) %>
#   <span class="ml-2">Enregistrement...</span>
#
class Foundation::SpinnerComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available sizes
  SIZES = %i[xs small medium large xl].freeze

  # Default size
  DEFAULT_SIZE = :medium

  # Available colors
  COLORS = %i[primary secondary success danger warning info white].freeze

  # Default color
  DEFAULT_COLOR = :primary

  # Size configurations (width/height and border-width)
  SIZE_CONFIG = {
    xs: { dimension: "w-3 h-3", border: "border-2" },
    small: { dimension: "w-4 h-4", border: "border-2" },
    medium: { dimension: "w-6 h-6", border: "border-2" },
    large: { dimension: "w-8 h-8", border: "border-[3px]" },
    xl: { dimension: "w-12 h-12", border: "border-4" }
  }.freeze

  # Color configurations
  COLOR_CONFIG = {
    primary: "border-indigo-600 border-t-transparent",
    secondary: "border-slate-600 border-t-transparent",
    success: "border-green-600 border-t-transparent",
    danger: "border-red-600 border-t-transparent",
    warning: "border-yellow-500 border-t-transparent",
    info: "border-sky-500 border-t-transparent",
    white: "border-white border-t-transparent"
  }.freeze

  # Text size for labels
  TEXT_SIZE_CONFIG = {
    xs: "text-xs",
    small: "text-sm",
    medium: "text-base",
    large: "text-lg",
    xl: "text-xl"
  }.freeze

  # @param size [Symbol] The spinner size (:xs, :small, :medium, :large, :xl)
  # @param color [Symbol] The spinner color (:primary, :secondary, :success, :danger, :warning, :info, :white)
  # @param label [String] Optional text label to display below spinner
  # @param aria_label [String] Custom ARIA label (defaults to "Chargement...")
  # @param centered [Boolean] Whether to center the spinner in its container
  # @param inline [Boolean] Whether to display inline (useful for inline loading states)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    size: DEFAULT_SIZE,
    color: DEFAULT_COLOR,
    label: nil,
    aria_label: nil,
    centered: false,
    inline: false,
    **html_attributes
  )
    @size = size.to_sym
    @color = color.to_sym
    @label = label
    @aria_label = aria_label || t_component("aria_label", default: "Chargement...")
    @centered = centered
    @inline = inline
    @html_attributes = html_attributes

    validate_size!
    validate_color!
  end

  private

  def merged_html_attributes
    deep_merge_attributes(
      { class: container_classes },
      @html_attributes
    )
  end

  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Valid sizes are: #{SIZES.join(', ')}"
  end

  def validate_color!
    return if COLORS.include?(@color)

    raise ArgumentError, "Invalid color: #{@color}. Valid colors are: #{COLORS.join(', ')}"
  end

  def container_classes
    classes = []

    if @centered
      classes << "flex flex-col items-center justify-center"
    elsif @inline
      classes << "inline-flex items-center"
    else
      classes << "flex items-center gap-2"
    end

    classes.compact.join(" ")
  end

  def spinner_classes
    config = SIZE_CONFIG[@size]
    classes = [
      config[:dimension],
      config[:border],
      COLOR_CONFIG[@color],
      "rounded-full animate-spin"
    ]

    classes.join(" ")
  end

  def label_classes
    classes = [
      TEXT_SIZE_CONFIG[@size],
      "text-slate-700 font-medium"
    ]

    classes << "mt-2" if @centered
    classes << "ml-2" unless @centered

    classes.join(" ")
  end

  def has_label?
    @label.present?
  end
end
