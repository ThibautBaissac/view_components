# frozen_string_literal: true

class Behavior::ClipboardComponent < ViewComponent::Base
  include HtmlAttributesRendering
  include I18nHelpers

  # Slot for custom trigger element (button, link, icon, etc.)
  renders_one :trigger

  # Strip trailing whitespace for clean rendering
  strip_trailing_whitespace

  VARIANTS = %i[button icon].freeze
  BUTTON_VARIANTS = %i[primary secondary outline ghost].freeze
  BUTTON_SIZES = %i[small medium large].freeze

  def initialize(
    value:,
    text: nil,
    success_text: nil,
    success_duration: 2000,
    variant: :button,
    button_variant: :outline,
    button_size: :medium,
    **html_attributes
  )
    @value = value
    @text = text
    @success_text = success_text
    @success_duration = success_duration
    @variant = variant
    @button_variant = button_variant
    @button_size = button_size
    @html_attributes = html_attributes

    validate_variant!
    validate_button_variant!
    validate_button_size!
  end

  # Check if component should render
  # Only render if value is present and not blank
  # @return [Boolean]
  def render?
    @value.present?
  end

  private

  def copy_text
    @text || t_component("copy", default: "Copy")
  end

  def success_text
    @success_text || t_component("copied", default: "Copied!")
  end

  def success_announcement
    t_component("copied_to_clipboard", default: "Copied to clipboard")
  end

  def error_announcement
    t_component("failed_to_copy", default: "Failed to copy to clipboard")
  end

  def copy_icon
    render(Foundation::IconComponent.new(name: "clipboard-document"))
  end

  def success_icon
    render(Foundation::IconComponent.new(name: "check", color: :success))
  end

  def wrapper_classes
    base = "inline-flex"
    [ base, @html_attributes[:class] ].compact.join(" ")
  end

  def button_classes
    base = "inline-flex items-center justify-center gap-2 font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2"

    variant_classes = case @button_variant
    when :primary
      "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500"
    when :secondary
      "bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500"
    when :outline
      "border-2 border-gray-300 text-gray-700 hover:bg-gray-50 focus:ring-gray-500"
    when :ghost
      "text-gray-700 hover:bg-gray-100 focus:ring-gray-500"
    else
      "border-2 border-gray-300 text-gray-700 hover:bg-gray-50 focus:ring-gray-500"
    end

    size_classes = case @button_size
    when :small
      "px-3 py-1.5 text-sm rounded"
    when :medium
      "px-4 py-2 text-base rounded-md"
    when :large
      "px-6 py-3 text-lg rounded-lg"
    else
      "px-4 py-2 text-base rounded-md"
    end

    [ base, variant_classes, size_classes ].join(" ")
  end

  def icon_only_classes
    "inline-flex items-center justify-center p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
  end

  def validate_variant!
    return if VARIANTS.include?(@variant)

    raise ArgumentError, "Invalid variant: #{@variant}. Valid variants are: #{VARIANTS.join(', ')}"
  end

  def validate_button_variant!
    return if BUTTON_VARIANTS.include?(@button_variant)

    raise ArgumentError, "Invalid button_variant: #{@button_variant}. Valid variants are: #{BUTTON_VARIANTS.join(', ')}"
  end

  def validate_button_size!
    return if BUTTON_SIZES.include?(@button_size)

    raise ArgumentError, "Invalid button_size: #{@button_size}. Valid sizes are: #{BUTTON_SIZES.join(', ')}"
  end
end
