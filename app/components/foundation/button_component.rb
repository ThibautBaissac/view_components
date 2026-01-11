# frozen_string_literal: true

# Button component with loading states and full accessibility support.
#
# Renders a <button> element with styling from BaseButtonComponent, adding
# support for loading states (with spinner and aria-busy), button types
# (button, submit, reset), and proper disabled semantics.
#
# @example Basic button
#   <%= render Foundation::ButtonComponent.new(text: "Save Changes") %>
#
# @example Submit button with variant
#   <%= render Foundation::ButtonComponent.new(
#     text: "Create Account",
#     type: :submit,
#     variant: :success
#   ) %>
#
# @example Loading button (disabled while loading)
#   <%= render Foundation::ButtonComponent.new(
#     text: "Processing",
#     loading: true,
#     variant: :primary
#   ) %>
#
# @example Disabled button
#   <%= render Foundation::ButtonComponent.new(
#     text: "Unavailable",
#     disabled: true,
#     variant: :secondary
#   ) %>
#
# @example With icon
#   <%= render Foundation::ButtonComponent.new(text: "Delete", variant: :danger) do |c| %>
#     <% c.with_icon_leading do %>
#       <%= render Foundation::IconComponent.new(name: "trash") %>
#     <% end %>
#   <% end %>
#
# @param text [String, nil] Button text content
# @param variant [Symbol] Visual style variant (default: :primary)
# @param size [Symbol] Size variant (default: :medium)
# @param disabled [Boolean] Whether the button is disabled
# @param loading [Boolean] Whether the button is in loading state (shows spinner, disables interaction)
# @param type [Symbol] HTML button type (:button, :submit, :reset) (default: :button)
# @param full_width [Boolean] Whether the button should span full width
# @param html_attributes [Hash] Additional HTML attributes
#
# @note Loading buttons are automatically disabled and show aria-busy="true"
# @note Loading state displays a spinner and hides icon slots
# @note Button type defaults to :button to prevent accidental form submission
#
# @see Foundation::BaseButtonComponent
# @see Foundation::LinkComponent
class Foundation::ButtonComponent < Foundation::BaseButtonComponent
  TYPES = %i[button submit reset].freeze

  def initialize(
    text: nil,
    variant: :primary,
    size: :medium,
    disabled: false,
    loading: false,
    type: :button,
    full_width: false,
    **html_attributes
  )
    @loading = loading
    @type = type

    super(
      text: text,
      variant: variant,
      size: size,
      disabled: disabled,
      full_width: full_width,
      **html_attributes
    )

    validate_type!
    validate_accessible_name!
  end

  private

  def merged_html_attributes
    attrs = @html_attributes.dup
    attrs[:disabled] = true if disabled?
    attrs[:type] = @type
    attrs[:"aria-disabled"] = "true" if disabled?
    attrs[:"aria-busy"] = "true" if @loading
    attrs
  end

  def disabled?
    @disabled || @loading
  end

  def loading?
    @loading
  end

  def validate_type!
    return if TYPES.include?(@type)

    raise ArgumentError, "Invalid type: #{@type}. Valid types are: #{TYPES.join(', ')}"
  end
end
