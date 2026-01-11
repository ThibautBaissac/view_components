# frozen_string_literal: true

# Feedback::AlertComponent
#
# A flexible alert component that displays contextual feedback messages.
# Supports different types (info, success, warning, error) with appropriate
# styling and icons. Can be dismissible with Stimulus integration.
#
# @example Basic info alert
#   <%= render Feedback::AlertComponent.new(message: "Information message") %>
#
# @example Success alert
#   <%= render Feedback::AlertComponent.new(message: "Success!", type: :success) %>
#
# @example Warning alert
#   <%= render Feedback::AlertComponent.new(message: "Warning!", type: :warning) %>
#
# @example Error alert
#   <%= render Feedback::AlertComponent.new(message: "Error occurred", type: :error) %>
#
# @example Dismissible alert
#   <%= render Feedback::AlertComponent.new(message: "You can dismiss this", dismissible: true) %>
#
# @example With custom title slot
#   <%= render Feedback::AlertComponent.new(message: "Details here", type: :success) do |alert| %>
#     <% alert.with_title { "Success!" } %>
#   <% end %>
#
# @example With custom icon
#   <%= render Feedback::AlertComponent.new(message: "Custom alert") do |alert| %>
#     <% alert.with_icon(name: "star", variant: :solid) %>
#   <% end %>
#
# @example With actions
#   <%= render Feedback::AlertComponent.new(message: "Alert with actions", type: :warning) do |alert| %>
#     <% alert.with_action(text: "View Details", url: "#") %>
#     <% alert.with_action(text: "Dismiss", url: "#") %>
#   <% end %>
#
class Feedback::AlertComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available alert types
  TYPES = %i[info success warning error].freeze

  # Default type
  DEFAULT_TYPE = :info

  # Type configurations with colors, icons, and styles
  TYPE_CONFIG = {
    info: {
      container_classes: "bg-sky-50 border-sky-200 text-slate-900 shadow-sm",
      icon_color: :info,
      icon_name: "information-circle"
    },
    success: {
      container_classes: "bg-green-50 border-green-200 text-slate-900 shadow-sm",
      icon_color: :success,
      icon_name: "check-circle"
    },
    warning: {
      container_classes: "bg-yellow-50 border-yellow-200 text-slate-900 shadow-sm",
      icon_color: :warning,
      icon_name: "exclamation-triangle"
    },
    error: {
      container_classes: "bg-red-50 border-red-200 text-slate-900 shadow-sm",
      icon_color: :danger,
      icon_name: "exclamation-triangle"
    }
  }.freeze

  # Slots
  renders_one :title
  renders_one :icon, Foundation::IconComponent
  renders_many :actions, ->(text:, url:, **options) do
    link_to text, url, class: action_classes, **options
  end

  # @param message [String] The alert message content (required)
  # @param type [Symbol] The alert type (:info, :success, :warning, :error)
  # @param dismissible [Boolean] Whether the alert can be dismissed
  # @param show_icon [Boolean] Whether to show the type icon (default: true)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    message:,
    type: DEFAULT_TYPE,
    dismissible: false,
    show_icon: true,
    **html_attributes
  )
    @message = message
    @type = type.to_sym
    @dismissible = dismissible
    @show_icon = show_icon
    @html_attributes = html_attributes

    validate_type!
  end

  # Check if alert should render
  # @return [Boolean]
  def render?
    @message.present?
  end

  private

  def validate_type!
    return if TYPES.include?(@type)

    raise ArgumentError, "Invalid type: #{@type}. Must be one of #{TYPES.join(', ')}"
  end

  def container_classes
    classes = [
      "alert",
      "flex items-start gap-3 px-4 py-3.5 border-l-4 rounded-lg",
      TYPE_CONFIG[@type][:container_classes]
    ]

    classes.join(" ")
  end

  def icon_classes
    "flex-shrink-0 mt-0.5"
  end

  def content_classes
    "flex-1 min-w-0"
  end

  def title_classes
    "font-semibold text-sm mb-1"
  end

  def message_classes
    "text-sm"
  end

  def action_classes
    "inline-flex items-center text-sm font-medium underline hover:no-underline focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-current rounded"
  end

  def actions_container_classes
    "flex gap-4 mt-2"
  end

  def controller_data
    return {} unless @dismissible

    { data: { controller: "components--alert" } }
  end

  def merged_html_attributes
    default_attrs = controller_data
    attrs = @html_attributes.except(:class)

    # Add ARIA attributes for accessibility
    attrs[:role] = "alert"
    attrs[:aria] ||= {}
    attrs[:aria][:live] = aria_live_value
    attrs[:aria][:atomic] = "true"

    default_attrs.deep_merge(attrs)
  end

  def computed_classes
    custom_class = @html_attributes[:class]
    [ container_classes, custom_class ].compact.join(" ")
  end

  # Use assertive for errors, polite for other types
  def aria_live_value
    @type == :error ? "assertive" : "polite"
  end

  def default_icon
    config = TYPE_CONFIG[@type]
    Foundation::IconComponent.new(
      name: config[:icon_name],
      color: config[:icon_color],
      size: :medium,
      variant: :outline
    )
  end

  def show_icon?
    @show_icon && !icon?
  end

  def show_actions?
    actions?
  end

  def dismiss_label
    t_component("dismiss", default: "Dismiss alert")
  end
end
