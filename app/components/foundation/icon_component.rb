# frozen_string_literal: true

# Flexible, accessible icon component that renders SVG icons.
#
# Renders SVG icons from file system or accepts custom SVG content. Icons are
# automatically cached for performance. Supports multiple icon sets (Heroicons,
# custom), variants (outline, solid, mini, micro), sizes, and colors.
#
# Provides comprehensive accessibility support with automatic ARIA attributes
# for both decorative and semantic icons. Labels can be plain strings or i18n
# keys for multilingual support.
#
# @example Basic usage with icon name
#   <%= render Foundation::IconComponent.new(name: "user") %>
#
# @example With variant (outline/solid/mini/micro)
#   <%= render Foundation::IconComponent.new(name: "heart", variant: :solid) %>
#
# @example With mini variant (20x20 optimized)
#   <%= render Foundation::IconComponent.new(name: "heart", variant: :mini) %>
#
# @example With micro variant (16x16 optimized)
#   <%= render Foundation::IconComponent.new(name: "heart", variant: :micro) %>
#
# @example With custom size
#   <%= render Foundation::IconComponent.new(name: "chevron-down", size: :large) %>
#
# @example With custom color
#   <%= render Foundation::IconComponent.new(name: "check", color: :success) %>
#
# @example With accessibility label (string)
#   <%= render Foundation::IconComponent.new(name: "warning", label: "Warning message") %>
#
# @example With accessibility label (i18n key for French support)
#   <%= render Foundation::IconComponent.new(name: "check", label: :success_checkmark) %>
#
# @example Icon-only (decorative) - hidden from screen readers
#   <%= render Foundation::IconComponent.new(name: "arrow-right") %>
#
# @example Custom SVG content
#   <%= render Foundation::IconComponent.new(custom: '<svg>...</svg>') %>
#
# @example From a different icon set
#   <%= render Foundation::IconComponent.new(name: "logo", set: :custom) %>
#
# @param name [String, Symbol, nil] Icon filename (without extension)
# @param set [Symbol] Icon set (:heroicons, :custom) (default: :heroicons)
# @param variant [Symbol] Icon variant (:outline, :solid, :mini, :micro) (default: :outline)
# @param size [Symbol] Icon size (:xs, :small, :medium, :large, :xl, :xxl) (default: :medium)
# @param color [Symbol] Icon color (:current, :primary, :secondary, :success, :warning, :danger, :info, :muted, :white, :black) (default: :current)
# @param label [String, Symbol, nil] Accessible label (plain string or i18n key for semantic icons)
# @param custom [String, nil] Custom SVG content (alternative to name parameter)
# @param html_attributes [Hash] Additional HTML attributes (class, id, data, aria, etc.)
#
# @note Decorative icons (without label) include aria-hidden="true" and focusable="false"
# @note Semantic icons (with label) include role="img" and aria-label
# @note Icons are cached with 1-hour expiration for performance
# @note All SVG content is sanitized to prevent XSS attacks
# @note Directory traversal protection prevents unauthorized file access
# @note Supports both French and English labels via i18n keys
#
# @see IconLoaderService For file loading and caching implementation
# @see Foundation::ButtonComponent For icon integration in buttons
# @see Foundation::BadgeComponent For icon integration in badges
#
class Foundation::IconComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers
  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Icon variants (style)
  VARIANTS = %i[outline solid mini micro].freeze

  # Predefined sizes with Tailwind classes
  SIZES = {
    xs: "w-3 h-3",
    small: "w-4 h-4",
    medium: "w-5 h-5",
    large: "w-6 h-6",
    xl: "w-8 h-8",
    xxl: "w-10 h-10"
  }.freeze

  # Predefined colors with Tailwind classes
  COLORS = {
    current: "text-current",
    primary: "text-blue-600",
    secondary: "text-gray-600",
    success: "text-green-600",
    warning: "text-yellow-600",
    danger: "text-red-600",
    info: "text-cyan-600",
    muted: "text-gray-400",
    white: "text-white",
    black: "text-gray-900"
  }.freeze

  # Default icon set
  DEFAULT_SET = :heroicons

  # Default variant
  DEFAULT_VARIANT = :outline
  def initialize(
    name: nil,
    set: DEFAULT_SET,
    variant: DEFAULT_VARIANT,
    size: :medium,
    color: :current,
    label: nil,
    custom: nil,
    **html_attributes
  )
    @name = name&.to_s
    @set = set
    @variant = variant
    @size = size
    @color = color
    @label = label
    @custom = custom
    @html_attributes = html_attributes

    validate_params!
  end

  # Prepare the rendered SVG content before rendering
  #
  # @return [void]
  def before_render
    svg_content = load_svg_content
    @rendered_svg = svg_content.present? ? modify_svg(svg_content) : ""
  end

  # Check if icon should be rendered
  #
  # @return [Boolean] true if icon can be rendered
  def render?
    @custom.present? || IconLoaderService.icon_exists?(
      name: @name,
      set: @set,
      variant: @variant
    )
  end

  # Class method to clear the icon cache (useful in development)
  #
  # @return [void]
  def self.clear_cache!
    IconLoaderService.clear_cache!
  end

  # Class method to list available icons for a set/variant
  #
  # @param set [Symbol] Icon set
  # @param variant [Symbol] Icon variant
  # @return [Array<String>] List of icon names
  def self.available_icons(set: DEFAULT_SET, variant: DEFAULT_VARIANT)
    IconLoaderService.available_icons(set: set, variant: variant)
  end

  # Class method to get icon directory path
  #
  # @param set [Symbol] Icon set
  # @param variant [Symbol] Icon variant
  # @return [Pathname] Directory path
  def self.icon_directory(set, variant)
    IconLoaderService.icon_directory(set, variant)
  end

  private

  # Load SVG content from file system or custom parameter
  #
  # @return [String, nil] SVG content or nil
  def load_svg_content
    if @custom.present?
      IconLoaderService.sanitize_svg(@custom)
    else
      IconLoaderService.load_icon(
        name: @name,
        set: @set,
        variant: @variant
      )
    end
  end

  def modify_svg(svg_content)
    doc = Nokogiri::HTML::DocumentFragment.parse(svg_content)
    svg = doc.at_css("svg")
    return svg_content unless svg

    apply_css_classes(svg)
    apply_accessibility_attributes(svg)
    apply_custom_attributes(svg)
    apply_data_attributes(svg)

    # Safe to call html_safe because content has been sanitized through
    # Rails::HTML5::SafeListSanitizer with strict allowlists
    doc.to_html.html_safe
  end

  def apply_css_classes(svg)
    existing_classes = svg["class"].to_s.split
    new_classes = [ size_classes, color_classes, @html_attributes[:class] ].compact.join(" ").split
    svg["class"] = (existing_classes + new_classes).uniq.join(" ")
  end

  # Apply accessibility attributes to SVG element
  #
  # Supports both string labels and i18n keys for multilingual support
  #
  # @param svg [Nokogiri::XML::Element] SVG element
  # @return [void]
  def apply_accessibility_attributes(svg)
    if @label.present?
      # Icon has meaning - add accessible label
      # Support both string and i18n key
      label_text = if @label.is_a?(Symbol)
        t_component(@label, default: @label.to_s.humanize)
      else
        @label.to_s
      end

      svg["role"] = "img"
      svg["aria-label"] = label_text
      svg.delete("aria-hidden")
    else
      # Decorative icon - hide from screen readers
      svg["aria-hidden"] = "true"
      svg["focusable"] = "false"
    end
  end

  # Apply custom HTML attributes to SVG element
  #
  # Uses HtmlAttributesRendering concern for consistent attribute handling
  #
  # @param svg [Nokogiri::XML::Element] SVG element
  # @return [void]
  def apply_custom_attributes(svg)
    # Merge additional HTML attributes
    @html_attributes.except(:class, :data).each do |key, value|
      next if value.nil?

      attr_name = key.to_s.tr("_", "-")
      svg[attr_name] = value.to_s
    end
  end

  # Apply data attributes to SVG element
  #
  # @param svg [Nokogiri::XML::Element] SVG element
  # @return [void]
  def apply_data_attributes(svg)
    # Handle data attributes specially
    return unless @html_attributes[:data].is_a?(Hash)

    @html_attributes[:data].each do |key, value|
      next if value.nil?

      attr_name = "data-#{key.to_s.tr('_', '-')}"
      svg[attr_name] = value.to_s
    end
  end

  def size_classes
    SIZES[@size] || SIZES[:medium]
  end

  def color_classes
    COLORS[@color] || COLORS[:current]
  end

  # Validate component parameters
  #
  # @raise [ArgumentError] if parameters are invalid
  # @return [void]
  def validate_params!
    if @name.blank? && @custom.blank?
      raise ArgumentError, "Either name or custom SVG content must be provided"
    end

    unless IconLoaderService::ICON_SETS.key?(@set)
      raise ArgumentError,
            "Invalid icon set: #{@set}. Valid sets: #{IconLoaderService::ICON_SETS.keys.join(', ')}"
    end

    unless VARIANTS.include?(@variant)
      raise ArgumentError, "Invalid variant: #{@variant}. Valid variants: #{VARIANTS.join(', ')}"
    end

    unless SIZES.key?(@size)
      raise ArgumentError, "Invalid size: #{@size}. Valid sizes: #{SIZES.keys.join(', ')}"
    end

    unless COLORS.key?(@color)
      raise ArgumentError, "Invalid color: #{@color}. Valid colors: #{COLORS.keys.join(', ')}"
    end
  end
end
