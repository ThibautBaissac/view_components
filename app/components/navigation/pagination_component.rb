# frozen_string_literal: true

# Navigation::PaginationComponent
#
# A flexible pagination component that wraps Pagy for displaying navigation links.
# Provides accessible, styled pagination with Turbo integration and customizable appearance.
#
# @example Basic usage with pagy object
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy) %>
#
# @example With custom size
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, size: :large) %>
#
# @example Compact variant for mobile
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, variant: :compact) %>
#
# @example Minimal variant (only prev/next)
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, variant: :minimal) %>
#
# @example With Turbo Frame integration
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, turbo_frame: "items_list") %>
#
# @example Custom ARIA label
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, aria_label: "Product pages") %>
#
# @example With page info display
#   <%= render Navigation::PaginationComponent.new(pagy: @pagy, show_info: true) %>
#
# @see Navigation::PaginationComponentPreview Lookbook previews
#
class Navigation::PaginationComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available variants
  VARIANTS = %i[default compact minimal].freeze

  # Default variant
  DEFAULT_VARIANT = :default

  # Available sizes
  SIZES = %i[small medium large].freeze

  # Default size
  DEFAULT_SIZE = :medium

  # Number of page slots for series
  DEFAULT_SLOTS = 7

  # Size configurations for buttons
  SIZE_CONFIG = {
    small: {
      button: "px-2.5 py-1.5 text-xs",
      icon: :xs,
      gap: "gap-1"
    },
    medium: {
      button: "px-3.5 py-2 text-sm",
      icon: :small,
      gap: "gap-1.5"
    },
    large: {
      button: "px-4 py-2.5 text-base",
      icon: :medium,
      gap: "gap-2"
    }
  }.freeze

  # @param pagy [Pagy::Offset, Pagy::Countless] The pagy pagination object
  # @param variant [Symbol] The display variant (:default, :compact, :minimal)
  # @param size [Symbol] The size of pagination buttons (:small, :medium, :large)
  # @param slots [Integer] Number of page slots to display (default: 7)
  # @param show_info [Boolean] Whether to display page info (e.g., "21-30 of 100")
  # @param turbo_frame [String, nil] Turbo Frame ID for navigation
  # @param turbo_action [String] Turbo action type (default: "advance")
  # @param aria_label [String] ARIA label for the navigation element
  # @param base_url [String, nil] Base URL for pagination links (defaults to current path)
  # @param page_key [String] Query parameter key for page number (default: "page")
  # @param html_attributes [Hash] Additional HTML attributes for the nav element
  def initialize(
    pagy:,
    variant: DEFAULT_VARIANT,
    size: DEFAULT_SIZE,
    slots: DEFAULT_SLOTS,
    show_info: false,
    turbo_frame: nil,
    turbo_action: "advance",
    aria_label: "Pagination",
    base_url: nil,
    page_key: "page",
    **html_attributes
  )
    @pagy = pagy
    @variant = variant
    @size = size
    @slots = slots
    @show_info = show_info
    @turbo_frame = turbo_frame
    @turbo_action = turbo_action
    @aria_label = aria_label
    @base_url = base_url
    @page_key = page_key
    @html_attributes = html_attributes

    validate_variant!
    validate_size!
    validate_slots!
  end

  # Don't render if there's only one page
  def render?
    @pagy.last > 1
  end

  private

  # Loads the series helper for generating page series
  # Memoized since it's called in loops
  def series
    @series ||= begin
      require "pagy/toolbox/helpers/support/series"
      @pagy.send(:series, slots: @slots)
    end
  end

  # Generate URL for a specific page
  # Uses Rails URL helpers to build the URL with the page parameter
  def page_url(page)
    base = base_path
    params = current_params.except(@page_key.to_s, @page_key.to_sym)
    params[@page_key] = page

    query = params.to_query
    query.empty? ? base : "#{base}?#{query}"
  end

  # Get base path for pagination URLs
  def base_path
    @base_url || current_path
  end

  # Get current path from request or fallback
  def current_path
    if helpers.respond_to?(:request) && helpers.request.present?
      helpers.request.path
    else
      "/"
    end
  end

  # Get current query parameters from request or empty hash
  def current_params
    return helpers.request.query_parameters if helpers.respond_to?(:request) && helpers.request.present?

    {}
  end

  # Navigation wrapper classes
  def nav_classes
    base = "flex items-center justify-center"

    [
      base,
      SIZE_CONFIG[@size][:gap],
      @html_attributes[:class]
    ].compact.join(" ")
  end

  # Container classes for the component
  def container_classes
    return "flex flex-col items-center gap-2" if @show_info

    ""
  end

  # Button base classes (shared)
  def button_base_classes
    [
      "inline-flex items-center justify-center font-semibold rounded-lg",
      "transition-all duration-200 focus:outline-none focus:ring-2",
      "focus:ring-indigo-500 focus:ring-offset-2",
      SIZE_CONFIG[@size][:button]
    ].join(" ")
  end

  # Active button classes (current page)
  def active_button_classes
    [
      button_base_classes,
      "bg-indigo-600 text-white cursor-default shadow-lg shadow-indigo-500/30"
    ].join(" ")
  end

  # Regular button classes (clickable pages)
  def link_button_classes
    [
      button_base_classes,
      "text-slate-700 bg-white border-2 border-slate-300",
      "hover:bg-slate-50 hover:border-slate-400 hover:text-slate-900 active:scale-95"
    ].join(" ")
  end

  # Disabled button classes (prev/next when unavailable)
  def disabled_button_classes
    [
      button_base_classes,
      "text-slate-400 bg-slate-100 border-2 border-slate-200 cursor-not-allowed opacity-60"
    ].join(" ")
  end

  # Gap/ellipsis classes
  def gap_classes
    [
      "inline-flex items-center justify-center text-slate-400",
      SIZE_CONFIG[@size][:button]
    ].join(" ")
  end

  # Link attributes for turbo integration
  def link_attributes(page, rel: nil)
    attrs = {}
    attrs[:href] = page_url(page)
    attrs[:rel] = rel if rel
    attrs[:"data-turbo-frame"] = @turbo_frame if @turbo_frame
    attrs[:"data-turbo-action"] = @turbo_action if @turbo_frame
    attrs
  end

  # Builds link attribute string
  def link_attributes_string(page, rel: nil)
    link_attributes(page, rel: rel).map do |key, value|
      "#{key}=\"#{ERB::Util.html_escape(value)}\""
    end.join(" ").html_safe
  end

  # Page info text (e.g., "21-30 of 100")
  def page_info
    t_component(
      "info",
      default: "%{from}–%{to} of %{count}",
      from: @pagy.from,
      to: @pagy.to,
      count: @pagy.count
    )
  end

  # Icon size based on component size
  def icon_size
    SIZE_CONFIG[@size][:icon]
  end

  # Previous page available?
  def previous?
    @pagy.previous.present?
  end

  # Next page available?
  def next?
    @pagy.next.present?
  end

  # Validation helpers
  def validate_variant!
    return if VARIANTS.include?(@variant)

    raise ArgumentError, "Invalid variant: #{@variant}. Valid variants are: #{VARIANTS.join(', ')}"
  end

  def validate_size!
    return if SIZES.include?(@size)

    raise ArgumentError, "Invalid size: #{@size}. Valid sizes are: #{SIZES.join(', ')}"
  end

  def validate_slots!
    return if @slots.is_a?(Integer) && @slots.positive?

    raise ArgumentError, "Invalid slots: #{@slots}. Must be a positive integer"
  end

  # Attributes for the nav element
  def nav_attributes
    attrs = @html_attributes.except(:class)
    attrs[:"aria-label"] = @aria_label
    attrs[:role] = "navigation"

    # Add ARIA live region for Turbo Frame updates
    if @turbo_frame
      attrs[:"aria-live"] = "polite"
      attrs[:"aria-atomic"] = "false"
    end

    # Stimulus controller integration
    attrs[:data] ||= {}
    attrs[:data][:controller] = "components--pagination"
    attrs[:data][:"components--pagination-current-page-value"] = current_page
    attrs[:data][:"components--pagination-total-pages-value"] = total_pages
    attrs[:data][:"components--pagination-turbo-frame-value"] = @turbo_frame if @turbo_frame
    attrs[:data][:action] = [
      "keydown->components--pagination#handleKeydown",
      "turbo:frame-load@window->components--pagination#handleFrameLoad"
    ].join(" ")

    attrs
  end

  # Current page for display
  def current_page
    @pagy.page
  end

  # Total pages
  def total_pages
    @pagy.last
  end

  # Helper methods for button text based on variant
  def prev_button_text
    case @variant
    when :minimal
      t_component("previous", default: "Previous")
    when :compact
      t_component("prev_short", default: "Prev")
    else
      nil
    end
  end

  def next_button_text
    case @variant
    when :minimal
      t_component("next", default: "Next")
    when :compact
      t_component("next_short", default: "Next")
    else
      nil
    end
  end

  # ARIA label helper methods
  def prev_button_aria_label
    t_component("previous_page_aria", default: "Previous page")
  end

  def next_button_aria_label
    t_component("next_page_aria", default: "Next page")
  end

  def page_aria_label(page_num)
    t_component("page_aria", default: "Page %{page}", page: page_num)
  end

  def current_page_aria_label(page_num)
    t_component("current_page_aria", default: "Page %{page}, current page", page: page_num)
  end

  def page_indicator_text
    t_component("page_of", default: "%{page} / %{total}", page: current_page, total: total_pages)
  end

  # Text spacing classes for button text
  def prev_text_classes
    case @variant
    when :minimal then "ml-1"
    when :compact then "sr-only sm:not-sr-only sm:ml-1"
    else ""
    end
  end

  def next_text_classes
    case @variant
    when :minimal then "mr-1"
    when :compact then "sr-only sm:not-sr-only sm:mr-1"
    else ""
    end
  end
end
