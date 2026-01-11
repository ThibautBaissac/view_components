# frozen_string_literal: true

# Flexible tooltip component for displaying contextual information on hover, focus, or tap.
#
# Provides accessible, keyboard-navigable tooltips with multiple positioning options,
# customizable sizes, and support for both plain text and rich HTML content. Automatically
# manages ARIA attributes for screen reader compatibility and includes comprehensive
# keyboard interaction (ESC to close, focus triggers display).
#
# Supports hover, focus, and touch interactions with configurable delay. Tooltips are
# initially hidden and transition smoothly when triggered. Arrow indicators can be
# optionally displayed to point toward the trigger element.
#
# @example Basic tooltip with plain text
#   <%= render Foundation::TooltipComponent.new(text: "Helpful tip") do %>
#     <button>Hover me</button>
#   <% end %>
#
# @example Tooltip positioned at bottom
#   <%= render Foundation::TooltipComponent.new(
#     text: "I appear below",
#     position: :bottom
#   ) do %>
#     <span>Hover for info</span>
#   <% end %>
#
# @example Large tooltip with rich content
#   <%= render Foundation::TooltipComponent.new(size: :large) do |tooltip| %>
#     <% tooltip.with_tooltip_content do %>
#       <div class="space-y-1">
#         <p class="font-semibold">Keyboard Shortcuts</p>
#         <p class="text-xs">Ctrl + S - Save</p>
#         <p class="text-xs">Ctrl + Z - Undo</p>
#       </div>
#     <% end %>
#     <button>View shortcuts</button>
#   <% end %>
#
# @example Tooltip on icon-only button
#   <%= render Foundation::TooltipComponent.new(text: "Delete item", position: :bottom) do %>
#     <%= tag.button(type: "button", "aria-label": "Delete") do %>
#       <%= render Foundation::IconComponent.new(name: "trash", color: :danger) %>
#     <% end %>
#   <% end %>
#
# @example Custom delay and no arrow
#   <%= render Foundation::TooltipComponent.new(
#     text: "I appear after 500ms",
#     delay: 500,
#     arrow: false
#   ) do %>
#     <button>Patient hover</button>
#   <% end %>
#
# @param text [String, nil] Plain text content for the tooltip (auto-escaped, ignored if tooltip_content slot is used)
# @param position [Symbol] Tooltip position relative to trigger (:top, :bottom, :left, :right) (default: :top)
# @param size [Symbol] Tooltip size controlling max-width and padding (:small, :medium, :large) (default: :medium)
# @param delay [Integer] Delay in milliseconds before showing tooltip on hover (default: 200, min: 0)
# @param arrow [Boolean] Whether to display arrow pointing to trigger element (default: true)
# @param html_attributes [Hash] Additional HTML attributes (class, id, data, aria, etc.)
#
# @note Tooltips use aria-describedby to link trigger to content for screen reader accessibility
# @note Keyboard accessible: Focus on trigger shows tooltip, ESC key hides it
# @note Touch accessible: Tap to show, tap again or tap elsewhere to hide
# @note Tooltips are initially hidden (opacity-0 invisible) and transition smoothly (200ms)
# @note Plain text (text parameter) is automatically escaped by Rails (XSS-safe)
# @note Rich content (tooltip_content slot) should be sanitized by caller to prevent XSS
# @note Tooltip positioning is CSS-based and does not automatically adjust for viewport edges
# @note Consider placement carefully when using near screen boundaries
# @note For tooltips with significant content, consider using a modal or popover instead
# @note Tooltips should be concise (1-2 sentences) for optimal accessibility
#
# @see Foundation::IconComponent For icons in tooltips and trigger buttons
# @see Foundation::ButtonComponent For button triggers with tooltips
# @see Layout::ModalComponent For complex overlay content requiring user interaction
# @see Navigation::DropdownMenuComponent For actionable tooltip-like menus
#
class Foundation::TooltipComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  strip_trailing_whitespace

  # Position options
  POSITIONS = %i[top bottom left right].freeze

  # Size options with Tailwind classes
  SIZES = {
    small: "text-xs px-2 py-1 max-w-xs",
    medium: "text-sm px-3 py-2 max-w-sm",
    large: "text-sm px-4 py-3 max-w-md"
  }.freeze

  # Default values
  DEFAULT_POSITION = :top
  DEFAULT_SIZE = :medium
  DEFAULT_DELAY = 200

  # Slot for rich tooltip content (alternative to text prop)
  renders_one :tooltip_content

  # @param text [String, nil] The tooltip text (ignored if slot is used)
  # @param position [Symbol] The tooltip position (:top, :bottom, :left, :right)
  # @param size [Symbol] The tooltip size (:small, :medium, :large)
  # @param delay [Integer] Delay in milliseconds before showing tooltip
  # @param arrow [Boolean] Whether to show the arrow
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    text: nil,
    position: DEFAULT_POSITION,
    size: DEFAULT_SIZE,
    delay: DEFAULT_DELAY,
    arrow: true,
    **html_attributes
  )
    @text = text
    @position = position.to_sym
    @size = size.to_sym
    @delay = delay
    @arrow = arrow
    @html_attributes = html_attributes

    validate_parameters!
  end

  # Check if tooltip should render
  # @return [Boolean]
  def render?
    content.present? && (@text.present? || tooltip_content?)
  end

  private

  def validate_parameters!
    validate_position!
    validate_size!
    validate_delay!
  end

  def validate_position!
    return if POSITIONS.include?(@position)

    raise ArgumentError,
      "Invalid position: #{@position}. Must be one of: #{POSITIONS.join(', ')}"
  end

  def validate_size!
    return if SIZES.key?(@size)

    raise ArgumentError,
      "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(', ')}"
  end

  def validate_delay!
    return if @delay.is_a?(Integer) && @delay >= 0

    raise ArgumentError,
      "Invalid delay: #{@delay}. Must be a non-negative integer"
  end

  def wrapper_classes
    "inline-block relative"
  end

  def tooltip_classes
    classes = [
      "absolute z-50 pointer-events-none",
      "bg-gray-900 text-white rounded-lg shadow-xl",
      "opacity-0 invisible",
      "transition-all duration-200",
      SIZES[@size],
      position_classes
    ]

    classes.join(" ")
  end

  def position_classes
    case @position
    when :top
      "bottom-full left-1/2 -translate-x-1/2 mb-2"
    when :bottom
      "top-full left-1/2 -translate-x-1/2 mt-2"
    when :left
      "right-full top-1/2 -translate-y-1/2 mr-2"
    when :right
      "left-full top-1/2 -translate-y-1/2 ml-2"
    end
  end

  def arrow_classes
    base = "absolute w-2 h-2 bg-gray-900 rotate-45"

    position_arrow = case @position
    when :top
      "top-full left-1/2 -translate-x-1/2 -mt-1"
    when :bottom
      "bottom-full left-1/2 -translate-x-1/2 -mb-1"
    when :left
      "left-full top-1/2 -translate-y-1/2 -ml-1"
    when :right
      "right-full top-1/2 -translate-y-1/2 -mr-1"
    end

    "#{base} #{position_arrow}"
  end

  def show_arrow?
    @arrow
  end

  def tooltip_text
    @text
  end

  def has_rich_content?
    tooltip_content?
  end

  def tooltip_id
    @tooltip_id ||= "tooltip-#{object_id}"
  end

  def controller_data
    {
      controller: "components--tooltip",
      "components--tooltip-delay-value": @delay,
      "components--tooltip-position-value": @position
    }
  end

  # Merged attributes for wrapper element
  #
  # Combines wrapper classes, controller data, and custom HTML attributes
  #
  # @return [Hash] Merged HTML attributes
  def merged_html_attributes_with_wrapper
    attrs = @html_attributes.dup
    custom_class = attrs.delete(:class)
    combined_class = [ wrapper_classes, custom_class ].compact.join(" ")

    {
      class: combined_class,
      data: controller_data
    }.deep_merge(attrs)
  end
end
