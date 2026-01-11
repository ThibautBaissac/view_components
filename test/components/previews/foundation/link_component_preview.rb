# frozen_string_literal: true

class Foundation::LinkComponentPreview < ViewComponent::Preview
  # Default link with primary variant
  # @label Default
  def default
    render(Foundation::LinkComponent.new(href: "#", text: "Click me"))
  end

  # All link variants side by side
  # @label All Variants
  def all_variants
    render_with_template(locals: {
      variants: Foundation::BaseButtonComponent::VARIANTS
    })
  end

  # All link sizes
  # @label All Sizes
  def all_sizes
    render_with_template(locals: {
      sizes: Foundation::BaseButtonComponent::SIZES
    })
  end

  # Link with disabled state
  # @label Disabled
  def disabled
    render(Foundation::LinkComponent.new(href: "#", text: "Disabled Link", disabled: true))
  end

  # Link with full width
  # @label Full Width
  def full_width
    render(Foundation::LinkComponent.new(href: "#", text: "Full Width Link", full_width: true))
  end

  # External link (opens in new tab)
  # @label External Link
  def external
    render(Foundation::LinkComponent.new(
      href: "https://example.com",
      text: "Visit Example.com",
      target: "_blank"
    ))
  end

  # Link with leading icon
  # @label With Leading Icon
  def with_leading_icon
    render(Foundation::LinkComponent.new(href: "#", text: "Back")) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M15 19l-7-7 7-7")
        end
      end
    end
  end

  # Link with trailing icon
  # @label With Trailing Icon
  def with_trailing_icon
    render(Foundation::LinkComponent.new(href: "#", text: "Next")) do |component|
      component.with_icon_trailing do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 5l7 7-7 7")
        end
      end
    end
  end

  # Link with both icons
  # @label With Both Icons
  def with_both_icons
    render(Foundation::LinkComponent.new(href: "#", text: "Share", variant: :success)) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z")
        end
      end
      component.with_icon_trailing do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14")
        end
      end
    end
  end

  # Icon-only link with aria-label
  # @label Icon Only
  def icon_only
    render(Foundation::LinkComponent.new(
      href: "#",
      variant: :ghost,
      "aria-label": "Go to settings"
    )) do |component|
      component.with_icon_leading do
        tag.svg(class: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z")
        end +
          tag.path(stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z")
      end
    end
  end

  # Comparison: Button vs Link with same styling
  # @label Button vs Link Comparison
  def button_vs_link
    render_with_template
  end

  # Different disabled variants
  # @label Disabled Variants
  def disabled_variants
    render_with_template(locals: {
      variants: [ :primary, :secondary, :outline, :ghost ]
    })
  end
end
