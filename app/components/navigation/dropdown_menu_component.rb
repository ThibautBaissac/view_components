# frozen_string_literal: true

# Navigation dropdown menu component with accessible keyboard navigation.
#
# This component renders a dropdown menu with customizable trigger, menu items,
# dividers, and section headers. It integrates with a Stimulus controller for
# interactive behavior including keyboard navigation and click-outside-to-close.
#
# @example Basic usage
#   <%= render Navigation::DropdownMenuComponent.new do |menu| %>
#     <% menu.with_item_link(text: "Profile", href: "/profile") %>
#     <% menu.with_item_link(text: "Settings", href: "/settings") %>
#     <% menu.with_item_divider %>
#     <% menu.with_item_link(text: "Sign out", href: "/logout", method: :delete, destructive: true) %>
#   <% end %>
#
# @example With custom trigger
#   <%= render Navigation::DropdownMenuComponent.new do |menu| %>
#     <% menu.with_trigger do %>
#       <button class="btn">Actions</button>
#     <% end %>
#     <% menu.with_item_button(text: "Export") %>
#   <% end %>
#
# @example With icons using IconComponent
#   <%= render Navigation::DropdownMenuComponent.new do |menu| %>
#     <% menu.with_item_link(text: "Edit", href: "#", icon: Foundation::IconComponent.new(name: "pencil-square", size: :small)) %>
#     <% menu.with_item_link(text: "Delete", href: "#", icon: Foundation::IconComponent.new(name: "trash", size: :small, color: :danger), destructive: true) %>
#   <% end %>
#
# @example With icon shorthand (symbol)
#   <%= render Navigation::DropdownMenuComponent.new do |menu| %>
#     <% menu.with_item_link(text: "Settings", href: "/settings", icon: :cog_6_tooth) %>
#     <% menu.with_item_link(text: "Profile", href: "/profile", icon: :user) %>
#   <% end %>
#
# @example With raw SVG icons (legacy, will be sanitized)
#   <%= render Navigation::DropdownMenuComponent.new do |menu| %>
#     <% menu.with_item_link(text: "Edit", href: "#", icon: '<svg class="w-4 h-4">...</svg>') %>
#   <% end %>
#
class Navigation::DropdownMenuComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Slot for the trigger element (button that opens the dropdown)
  renders_one :trigger

  # Slots for menu items with polymorphic types
  renders_many :items, types: {
    link: ->(text:, href:, icon: nil, destructive: false, disabled: false, method: :get, **html_attributes) do
      Navigation::DropdownMenuComponent::LinkItemComponent.new(
        text: text,
        href: href,
        icon: icon,
        destructive: destructive,
        disabled: disabled,
        method: method,
        **html_attributes
      )
    end,
    button: ->(text:, icon: nil, destructive: false, disabled: false, **html_attributes) do
      Navigation::DropdownMenuComponent::ButtonItemComponent.new(
        text: text,
        icon: icon,
        destructive: destructive,
        disabled: disabled,
        **html_attributes
      )
    end,
    divider: -> do
      Navigation::DropdownMenuComponent::DividerComponent.new
    end,
    header: ->(text:, **html_attributes) do
      Navigation::DropdownMenuComponent::HeaderComponent.new(text: text, **html_attributes)
    end
  }

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Allowed SVG elements and attributes for icon sanitization
  ALLOWED_ICON_TAGS = %w[svg path circle rect line polyline polygon ellipse g defs clipPath use].freeze
  ALLOWED_ICON_ATTRIBUTES = %w[
    class viewBox fill stroke stroke-width stroke-linecap stroke-linejoin
    d cx cy r rx ry x y x1 y1 x2 y2 points width height transform
    xmlns aria-hidden clip-path id href xlink:href
  ].freeze

  PLACEMENTS = %i[bottom_start bottom_end top_start top_end].freeze
  WIDTHS = %i[auto small medium large full].freeze

  # Placement configuration with Tailwind positioning classes
  PLACEMENT_CONFIG = {
    bottom_start: "top-full left-0",
    bottom_end: "top-full right-0",
    top_start: "bottom-full left-0 mb-2 mt-0",
    top_end: "bottom-full right-0 mb-2 mt-0"
  }.freeze

  # @param placement [Symbol] Position of dropdown relative to trigger
  #   (:bottom_start, :bottom_end, :top_start, :top_end)
  # @param width [Symbol] Width of dropdown menu (:auto, :small, :medium, :large, :full)
  # @param close_on_select [Boolean] Whether to close dropdown when an item is selected
  # @param html_attributes [Hash] Additional HTML attributes for the wrapper element
  def initialize(
    placement: :bottom_start,
    width: :auto,
    close_on_select: true,
    **html_attributes
  )
    @placement = placement
    @width = width
    @close_on_select = close_on_select
    @html_attributes = html_attributes
    @trigger_id = "dropdown-trigger-#{SecureRandom.hex(4)}"
    @menu_id = "dropdown-menu-#{SecureRandom.hex(4)}"

    validate_placement!
    validate_width!
  end

  # Unique ID for the trigger element (used for aria-labelledby)
  attr_reader :trigger_id, :menu_id

  # Default trigger button text (translated)
  def default_trigger_text
    t_component("default_trigger_text", default: "Options")
  end

  # Default trigger ARIA label (translated)
  def default_trigger_label
    t_component("default_trigger_label", default: "Menu options")
  end

  private

  def wrapper_classes
    base = "relative inline-block"
    [ base, @html_attributes[:class] ].compact.join(" ")
  end

  def menu_classes
    base = "absolute z-50 mt-2 rounded-xl bg-white shadow-lg ring-1 ring-slate-200 focus:outline-none"

    [
      base,
      width_class,
      placement_classes,
      "hidden" # Initially hidden
    ].compact.join(" ")
  end

  def width_class
    case @width
    when :auto
      "min-w-48"
    when :small
      "w-40"
    when :medium
      "w-56"
    when :large
      "w-72"
    when :full
      "w-full"
    else
      "min-w-48"
    end
  end

  def placement_classes
    PLACEMENT_CONFIG[@placement] || PLACEMENT_CONFIG[:bottom_start]
  end

  def data_attributes
    {
      controller: "components--dropdown",
      "components--dropdown-close-on-select-value": @close_on_select,
      "components--dropdown-placement-value": @placement.to_s.tr("_", "-"),
      "components--dropdown-opened-message-value": t_component("menu_opened", default: "Menu opened"),
      "components--dropdown-closed-message-value": t_component("menu_closed", default: "Menu closed")
    }
  end

  def wrapper_html_attributes
    {
      class: wrapper_classes,
      data: data_attributes
    }.deep_merge(@html_attributes.except(:class))
  end

  def validate_placement!
    return if PLACEMENTS.include?(@placement)

    raise ArgumentError, "Invalid placement: #{@placement}. Valid placements are: #{PLACEMENTS.join(', ')}"
  end

  def validate_width!
    return if WIDTHS.include?(@width)

    raise ArgumentError, "Invalid width: #{@width}. Valid widths are: #{WIDTHS.join(', ')}"
  end

  # Sanitize icon HTML to prevent XSS attacks.
  # Only allows safe SVG elements and attributes.
  #
  # WHEN TO USE THIS METHOD:
  # - This sanitization is ONLY needed for legacy support when raw HTML/SVG strings are provided
  # - RECOMMENDED: Use Foundation::IconComponent instead, which is pre-sanitized and trusted
  # - ALTERNATIVE: Use symbol shorthand (e.g., icon: :user) which creates a trusted IconComponent
  #
  # SECURITY NOTE:
  # Raw HTML strings from untrusted sources (user input, external APIs) MUST be sanitized.
  # IconComponent instances and symbols are trusted and bypass sanitization.
  #
  # @example Trusted IconComponent (NO sanitization needed)
  #   menu.with_item_link(text: "Edit", icon: Foundation::IconComponent.new(name: "pencil"))
  #
  # @example Symbol shorthand (NO sanitization needed)
  #   menu.with_item_link(text: "Settings", icon: :cog_6_tooth)
  #
  # @example Raw SVG string (WILL be sanitized)
  #   menu.with_item_link(text: "Edit", icon: '<svg>...</svg>')
  #
  # @param icon [String, nil] Raw icon HTML string
  # @return [ActiveSupport::SafeBuffer, nil] Sanitized HTML or nil
  def self.sanitize_icon(icon)
    return nil unless icon.is_a?(String)

    ActionController::Base.helpers.sanitize(
      icon,
      tags: ALLOWED_ICON_TAGS,
      attributes: ALLOWED_ICON_ATTRIBUTES
    )
  end

  # ============================================================================
  # Nested Components for Menu Items
  # ============================================================================

  # Base class for menu items
  class BaseItemComponent < ViewComponent::Base
    strip_trailing_whitespace

    # Focus state classes for keyboard navigation (used by Stimulus controller)
    FOCUS_CLASSES = "bg-slate-100 text-slate-900 outline-none".freeze

    def initialize(text: nil, icon: nil, destructive: false, disabled: false, **html_attributes)
      @text = text
      @icon = icon
      @destructive = destructive
      @disabled = disabled
      @html_attributes = html_attributes
    end

    private

    def item_classes
      base = "flex w-full items-center gap-2 px-4 py-2 text-sm transition-colors"

      state_classes = if @disabled
        "text-slate-500 cursor-not-allowed"
      elsif @destructive
        "text-red-600 hover:bg-red-50 hover:text-red-700 focus:bg-red-50 focus:outline-none"
      else
        "text-slate-700 hover:bg-slate-100 hover:text-slate-900 focus:bg-slate-100 focus:outline-none"
      end

      [ base, state_classes, @html_attributes[:class] ].compact.join(" ")
    end

    def data_attributes
      attrs = { "components--dropdown-target": "item" }
      attrs[:action] = "click->components--dropdown#select" unless @disabled
      attrs
    end

    def item_html_attributes
      {
        class: item_classes,
        role: "menuitem",
        data: data_attributes
      }.merge(@html_attributes.except(:class))
    end

    # Sanitize and return icon HTML
    # Accepts:
    # - String: raw SVG HTML (will be sanitized)
    # - ViewComponent::Base: rendered directly (e.g., Foundation::IconComponent)
    # - Proc/Lambda: called and result sanitized
    # - Symbol: icon name for Foundation::IconComponent
    #
    # @return [ActiveSupport::SafeBuffer, nil]
    def icon_html
      return nil unless @icon

      case @icon
      when ViewComponent::Base
        # Render the component directly (e.g., Foundation::IconComponent instance)
        render(@icon)
      when Symbol
        # Shorthand: icon name as symbol creates an IconComponent
        render(Foundation::IconComponent.new(name: @icon.to_s, size: :small))
      when String
        Navigation::DropdownMenuComponent.sanitize_icon(@icon)
      when Proc
        result = @icon.call
        if result.is_a?(ViewComponent::Base)
          render(result)
        else
          Navigation::DropdownMenuComponent.sanitize_icon(result)
        end
      else
        nil
      end
    end
  end

  # Link item component
  class LinkItemComponent < BaseItemComponent
    def initialize(text:, href:, icon: nil, destructive: false, disabled: false, method: :get, **html_attributes)
      @href = href
      @method = method
      super(text: text, icon: icon, destructive: destructive, disabled: disabled, **html_attributes)
    end

    def call
      if @disabled
        content_tag(:span, item_content, class: item_classes, role: "menuitem", "data-components--dropdown-target": "item", "aria-disabled": "true")
      else
        # Build data attributes with turbo_method for non-GET requests
        link_data = data_attributes.except(:"components--dropdown-target").merge("components--dropdown-target": "item")
        link_data[:turbo_method] = @method unless @method == :get

        link_to(@href, class: item_classes, role: "menuitem", data: link_data) do
          item_content
        end
      end
    end

    private

    def item_content
      capture do
        concat(icon_html) if @icon
        concat(content_tag(:span, @text))
      end
    end
  end

  # Button item component
  class ButtonItemComponent < BaseItemComponent
    def initialize(text:, icon: nil, destructive: false, disabled: false, **html_attributes)
      super(text: text, icon: icon, destructive: destructive, disabled: disabled, **html_attributes)
    end

    def call
      button_attrs = {
        type: "button",
        class: item_classes,
        role: "menuitem",
        disabled: @disabled || nil,
        "aria-disabled": @disabled ? "true" : nil
      }.merge(data_attributes.transform_keys { |k| "data-#{k.to_s.tr('_', '-')}" })

      content_tag(:button, button_attrs.compact) do
        capture do
          concat(icon_html) if @icon
          concat(content_tag(:span, @text))
        end
      end
    end
  end

  # Divider component
  class DividerComponent < ViewComponent::Base
    strip_trailing_whitespace

    def call
      content_tag(:div, nil, class: "my-1 border-t border-slate-200", role: "separator", "data-divider": true)
    end
  end

  # Header component (for grouping items)
  class HeaderComponent < ViewComponent::Base
    strip_trailing_whitespace

    def initialize(text:, **html_attributes)
      @text = text
      @html_attributes = html_attributes
    end

    def call
      classes = "px-4 py-2 text-xs font-semibold text-slate-600 uppercase tracking-wider #{@html_attributes[:class]}".strip
      content_tag(:div, @text, class: classes, role: "presentation")
    end
  end
end
