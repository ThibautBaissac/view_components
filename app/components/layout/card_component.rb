# frozen_string_literal: true

# Layout::CardComponent
#
# A flexible card component for displaying content in a styled container.
# Supports optional header with title/actions, footer, and sticky positioning.
#
# @example Basic card
#   <%= render Layout::CardComponent.new do %>
#     Card content here
#   <% end %>
#
# @example Card with header
#   <%= render Layout::CardComponent.new do |card| %>
#     <% card.with_header(title: "Event Details") %>
#     Card content here
#   <% end %>
#
# @example Card with actions in header
#   <%= render Layout::CardComponent.new do |card| %>
#     <% card.with_header(title: "Vendors") do %>
#       <%= render Foundation::ButtonComponent.new(text: "Add", variant: :primary) %>
#     <% end %>
#     Card content here
#   <% end %>
#
# @example Sticky sidebar card
#   <%= render Layout::CardComponent.new(sticky: true) do |card| %>
#     <% card.with_header(title: "Actions") %>
#     Action buttons here
#   <% end %>
#
# @example Card with footer
#   <%= render Layout::CardComponent.new do |card| %>
#     <% card.with_header(title: "Summary") %>
#     Content
#     <% card.with_footer do %>
#       Total: €1,234
#     <% end %>
#   <% end %>
#
class Layout::CardComponent < ViewComponent::Base
  include HtmlAttributesRendering

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available padding sizes
  PADDINGS = %i[none small medium large].freeze

  # Default padding
  DEFAULT_PADDING = :large

  # Padding configurations
  PADDING_CONFIG = {
    none: "",
    small: "p-4",
    medium: "p-6",
    large: "p-8"
  }.freeze

  # Header padding configurations (match content padding)
  HEADER_PADDING_CONFIG = {
    none: "px-0 pt-0",
    small: "px-4 pt-4",
    medium: "px-6 pt-6",
    large: "px-8 pt-8"
  }.freeze

  # Footer padding configurations (match content padding)
  FOOTER_PADDING_CONFIG = {
    none: "px-0 pb-0 pt-0",
    small: "px-4 pb-4 pt-2",
    medium: "px-6 pb-6 pt-3",
    large: "px-8 pb-8 pt-4"
  }.freeze

  # Slots
  renders_one :header, lambda { |title: nil, &block|
    HeaderComponent.new(title: title, padding: @padding, &block)
  }
  renders_one :footer

  # @param padding [Symbol] Card padding size (:none, :small, :medium, :large)
  # @param sticky [Boolean] Whether to make card sticky (useful for sidebars)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    padding: DEFAULT_PADDING,
    sticky: false,
    **html_attributes
  )
    @padding = padding.to_sym
    @sticky = sticky
    @html_attributes = html_attributes

    validate_padding!
  end

  private

  def card_classes
    classes = [
      "bg-white rounded-2xl border border-slate-200/70",
      sticky_classes,
      @html_attributes[:class]
    ].compact

    classes.join(" ")
  end

  def sticky_classes
    "sticky top-6" if @sticky
  end

  def content_padding_classes
    PADDING_CONFIG[@padding] || PADDING_CONFIG[:large]
  end

  def footer_padding_classes
    FOOTER_PADDING_CONFIG[@padding] || FOOTER_PADDING_CONFIG[:large]
  end

  def merged_html_attributes
    @html_attributes.except(:class)
  end

  def validate_padding!
    return if PADDINGS.include?(@padding)

    raise ArgumentError, "Invalid padding: #{@padding}. Must be one of #{PADDINGS.join(', ')}"
  end

  # Header component for card title and actions
  class HeaderComponent < ViewComponent::Base
    strip_trailing_whitespace

    def initialize(title: nil, padding: :large)
      @title = title
      @padding = padding
    end

    attr_reader :title

    def call
      tag.div(class: header_padding_classes) do
        parts = []

        if @title.present?
          parts << tag.h2(@title, class: "text-lg font-semibold text-slate-900 mb-4 pb-2 border-b border-slate-200")
        end

        if content.present?
          parts << tag.div(content, class: "mb-4")
        end

        safe_join(parts)
      end
    end

    private

    def header_padding_classes
      base = Layout::CardComponent::HEADER_PADDING_CONFIG[@padding] || Layout::CardComponent::HEADER_PADDING_CONFIG[:large]
      "#{base} pb-0"
    end
  end
end
