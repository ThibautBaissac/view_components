# frozen_string_literal: true

class Foundation::ButtonComponentPreview < ViewComponent::Preview
  # Default button with primary variant
  # @label Default
  def default
    render(Foundation::ButtonComponent.new(text: "Click me"))
  end

  # All button variants side by side
  # @label All Variants
  def all_variants
    render_with_template(locals: {
      variants: Foundation::BaseButtonComponent::VARIANTS
    })
  end

  # All button sizes
  # @label All Sizes
  def all_sizes
    render_with_template(locals: {
      sizes: Foundation::BaseButtonComponent::SIZES
    })
  end

  # Button with disabled state
  # @label Disabled
  def disabled
    render(Foundation::ButtonComponent.new(text: "Disabled Button", disabled: true))
  end

  # Button with loading state
  # @label Loading
  def loading
    render(Foundation::ButtonComponent.new(text: "Saving...", loading: true, variant: :primary))
  end

  # Button with full width
  # @label Full Width
  def full_width
    render(Foundation::ButtonComponent.new(text: "Full Width Button", full_width: true))
  end

  # Button with leading icon
  # @label With Leading Icon
  def with_leading_icon
    render(Foundation::ButtonComponent.new(text: "Download")) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4")
        end
      end
    end
  end

  # Button with trailing icon
  # @label With Trailing Icon
  def with_trailing_icon
    render(Foundation::ButtonComponent.new(text: "Next")) do |component|
      component.with_icon_trailing do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 5l7 7-7 7")
        end
      end
    end
  end

  # Button with both icons
  # @label With Both Icons
  def with_both_icons
    render(Foundation::ButtonComponent.new(text: "Share", variant: :success)) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z")
        end
      end
      component.with_icon_trailing do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 5l7 7-7 7")
        end
      end
    end
  end

  # Icon-only button (no text)
  # @label Icon Only
  def icon_only
    render(Foundation::ButtonComponent.new(variant: :ghost, aria: { label: "Settings" })) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z")
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z")
        end
      end
    end
  end

  # Button with custom HTML attributes
  # @label With Custom Attributes
  def with_custom_attributes
    render(Foundation::ButtonComponent.new(
      text: "Custom Button",
      id: "custom-button",
      data: { controller: "custom", action: "click->custom#handle" },
      class: "shadow-xl"
    ))
  end

  # Submit button for forms
  # @label Submit Button
  def submit_button
    render(Foundation::ButtonComponent.new(
      text: "Submit Form",
      type: :submit,
      variant: :success,
      size: :large
    ))
  end

  # Accessibility example with icon-only button
  # @label Accessible Icon Button
  def accessible_icon_button
    render(Foundation::ButtonComponent.new(
      variant: :ghost,
      aria: { label: "Close dialog" }
    )) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M6 18L18 6M6 6l12 12")
        end
      end
    end
  end

  # Interactive playground with dynamic parameters
  # @label Playground
  # @param variant select [primary, secondary, success, danger, warning, outline, ghost, link] "Variant"
  # @param size select [small, medium, large] "Size"
  # @param disabled toggle "Disabled"
  # @param loading toggle "Loading"
  # @param full_width toggle "Full Width"
  def playground(variant: "primary", size: "medium", disabled: false, loading: false, full_width: false)
    render(Foundation::ButtonComponent.new(
      text: "Button Text",
      variant: variant.to_sym,
      size: size.to_sym,
      disabled: disabled,
      loading: loading,
      full_width: full_width
    ))
  end
end
