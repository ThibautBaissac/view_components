# frozen_string_literal: true

# Feedback::ToastComponent
#
# A toast notification component that displays temporary feedback messages.
# Toasts appear briefly to provide feedback on user actions and auto-dismiss
# after a configurable timeout. Supports different types with appropriate
# styling and icons.
#
# @example Basic info toast
#   <%= render Feedback::ToastComponent.new(message: "Information message") %>
#
# @example Success toast
#   <%= render Feedback::ToastComponent.new(message: "Saved!", type: :success) %>
#
# @example Warning toast
#   <%= render Feedback::ToastComponent.new(message: "Warning!", type: :warning) %>
#
# @example Error toast (no auto-dismiss by default)
#   <%= render Feedback::ToastComponent.new(message: "Error occurred", type: :error) %>
#
# @example With custom timeout
#   <%= render Feedback::ToastComponent.new(message: "Quick toast", timeout: 2000) %>
#
# @example With title slot
#   <%= render Feedback::ToastComponent.new(message: "Details here", type: :success) do |toast| %>
#     <% toast.with_title { "Success!" } %>
#   <% end %>
#
# @example With custom icon
#   <%= render Feedback::ToastComponent.new(message: "Custom toast") do |toast| %>
#     <% toast.with_icon(name: "star", variant: :solid) %>
#   <% end %>
#
# @example With action
#   <%= render Feedback::ToastComponent.new(message: "Item deleted", type: :info) do |toast| %>
#     <% toast.with_action(text: "Undo", url: "#") %>
#   <% end %>
#
# @example Non-dismissible toast
#   <%= render Feedback::ToastComponent.new(message: "Processing...", dismissible: false, timeout: nil) %>
#
class Feedback::ToastComponent < ViewComponent::Base
  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  # Available toast types
  TYPES = %i[info success warning error].freeze

  # Default type
  DEFAULT_TYPE = :info

  # Default timeout in milliseconds (5 seconds)
  DEFAULT_TIMEOUT = 5000

  # Type configurations with colors, icons, and styles
  TYPE_CONFIG = {
    info: {
      container_classes: "bg-white border-slate-300 text-slate-900 shadow-xl",
      icon_color: :info,
      icon_name: "information-circle",
      auto_dismiss: true
    },
    success: {
      container_classes: "bg-white border-green-300 text-slate-900 shadow-xl",
      icon_color: :success,
      icon_name: "check-circle",
      auto_dismiss: true
    },
    warning: {
      container_classes: "bg-white border-yellow-300 text-slate-900 shadow-xl",
      icon_color: :warning,
      icon_name: "exclamation-triangle",
      auto_dismiss: true
    },
    error: {
      container_classes: "bg-white border-red-300 text-slate-900 shadow-xl",
      icon_color: :danger,
      icon_name: "exclamation-circle",
      auto_dismiss: false # Errors don't auto-dismiss by default
    }
  }.freeze

  # Slots
  renders_one :title
  renders_one :icon, Foundation::IconComponent
  renders_one :action, ->(text:, url: nil, **options, &block) do
    if url
      link_to text, url, class: action_classes, **options
    else
      tag.button(text, type: "button", class: action_classes, **options, &block)
    end
  end

  # @param message [String] The toast message content (required)
  # @param type [Symbol] The toast type (:info, :success, :warning, :error)
  # @param dismissible [Boolean] Whether the toast can be manually dismissed (default: true)
  # @param timeout [Integer, nil] Auto-dismiss timeout in milliseconds (nil to disable)
  # @param show_icon [Boolean] Whether to show the type icon (default: true)
  # @param show_progress [Boolean] Whether to show progress bar for auto-dismiss (default: true)
  # @param html_attributes [Hash] Additional HTML attributes
  def initialize(
    message:,
    type: DEFAULT_TYPE,
    dismissible: true,
    timeout: nil,
    show_icon: true,
    show_progress: true,
    **html_attributes
  )
    @message = message
    @type = type.to_sym
    @dismissible = dismissible
    @show_icon = show_icon
    @show_progress = show_progress
    @html_attributes = html_attributes
    @explicit_timeout = !timeout.nil?

    # Validate type first before using it
    validate_type!

    # Set timeout based on type if not explicitly provided
    @timeout = @explicit_timeout ? timeout : default_timeout_for_type
  end

  # Check if toast should render
  # @return [Boolean]
  def render?
    @message.present?
  end

  private

  def validate_type!
    return if TYPES.include?(@type)

    raise ArgumentError, "Invalid type: #{@type}. Must be one of #{TYPES.join(', ')}"
  end

  def default_timeout_for_type
    TYPE_CONFIG[@type][:auto_dismiss] ? DEFAULT_TIMEOUT : nil
  end

  def container_classes
    classes = [
      "toast",
      "flex items-start gap-3 px-4 py-3.5 border-l-4 rounded-xl shadow-2xl",
      "min-w-[320px] max-w-[420px]",
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
    "font-bold text-sm text-slate-900"
  end

  def message_classes
    "text-sm text-slate-600"
  end

  def action_classes
    "text-sm font-medium text-indigo-600 hover:text-indigo-800 focus:outline-none focus:underline"
  end

  def progress_bar_classes
    base = "absolute bottom-0 left-0 h-1 rounded-bl-xl transition-all"
    color = case @type
    when :success then "bg-green-500"
    when :warning then "bg-yellow-500"
    when :error then "bg-red-500"
    else "bg-sky-500"
    end

    "#{base} #{color}"
  end

  def controller_data
    data = { controller: "components--toast" }
    data[:components__toast_timeout_value] = @timeout if @timeout && @timeout > 0
    data[:components__toast_auto_dismiss_value] = @timeout.present? && @timeout > 0
    { data: data }
  end

  def merged_html_attributes
    default_attrs = controller_data
    default_attrs.deep_merge(@html_attributes)
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

  def show_progress_bar?
    @show_progress && @timeout.present? && @timeout > 0
  end

  def show_dismiss_button?
    @dismissible
  end

  def icon_border_color_class
    case @type
    when :success then "border-l-green-500"
    when :warning then "border-l-yellow-500"
    when :error then "border-l-red-500"
    else "border-l-sky-500"
    end
  end
end
