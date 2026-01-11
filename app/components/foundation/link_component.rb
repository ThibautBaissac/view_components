# frozen_string_literal: true

# Link component styled as a button with full accessibility support.
#
# Renders an anchor (<a>) element with button-like styling, supporting all variants
# and sizes from BaseButtonComponent. Automatically adds security attributes
# (rel="noopener noreferrer") for external links with target="_blank".
#
# @example Basic link
#   <%= render Foundation::LinkComponent.new(text: "View Details", href: "/items/1") %>
#
# @example External link with security
#   <%= render Foundation::LinkComponent.new(
#     text: "Visit Site",
#     href: "https://example.com",
#     target: "_blank",
#     variant: :outline
#   ) %>
#
# @example Disabled link (non-interactive)
#   <%= render Foundation::LinkComponent.new(
#     text: "Unavailable",
#     href: "/locked",
#     disabled: true
#   ) %>
#
# @example With icon
#   <%= render Foundation::LinkComponent.new(text: "Download", href: "/file.pdf", variant: :success) do |c| %>
#     <% c.with_icon_leading do %>
#       <%= render Foundation::IconComponent.new(name: "download") %>
#     <% end %>
#   <% end %>
#
# @param href [String] The URL the link points to (required)
# @param text [String, nil] Link text content
# @param variant [Symbol] Visual style variant (default: :primary)
# @param size [Symbol] Size variant (default: :medium)
# @param disabled [Boolean] Whether the link is disabled (adds aria-disabled, removes from tab order)
# @param full_width [Boolean] Whether the link should span full width
# @param target [String, nil] Link target attribute (e.g., "_blank", "_self")
# @param rel [String, nil] Link rel attribute (auto-enhanced with security attributes for external links)
# @param html_attributes [Hash] Additional HTML attributes
#
# @note Disabled links have href set to nil, aria-disabled="true", tabindex="-1", and pointer-events-none
# @note External links (_blank) automatically get rel="noopener noreferrer" for security
#
# @see Foundation::BaseButtonComponent
# @see Foundation::ButtonComponent
class Foundation::LinkComponent < Foundation::BaseButtonComponent
  def initialize(
    href:,
    text: nil,
    variant: :primary,
    size: :medium,
    disabled: false,
    full_width: false,
    target: nil,
    rel: nil,
    **html_attributes
  )
    @href = href
    @target = target
    @rel = rel

    super(
      text: text,
      variant: variant,
      size: size,
      disabled: disabled,
      full_width: full_width,
      **html_attributes
    )

    validate_accessible_name!
  end

  private

  def merged_html_attributes
    attrs = @html_attributes.dup
    attrs[:target] = @target if @target.present?
    attrs[:rel] = link_rel if link_rel.present?
    attrs[:"aria-disabled"] = "true" if disabled?
    attrs[:tabindex] = "-1" if disabled?
    attrs
  end

  def link_rel
    # Auto-add noopener noreferrer for external links with target="_blank"
    if @target == "_blank"
      [ @rel, "noopener", "noreferrer" ].compact.uniq.join(" ")
    else
      @rel
    end
  end
end
