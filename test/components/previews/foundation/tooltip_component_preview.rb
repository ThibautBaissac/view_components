# frozen_string_literal: true

# @label Tooltip
# @logical_path Foundation
class Foundation::TooltipComponentPreview < ViewComponent::Preview
  # Default tooltip
  # @label Default
  # @note
  #   The default tooltip appears above the trigger element.
  #   Hover over the button to see the tooltip.
  def default
    render(Foundation::TooltipComponent.new(text: "This is a helpful tooltip")) do
      tag.button("Hover me", type: "button", class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700")
    end
  end

  # All positions
  # @label Positions
  # @note
  #   Tooltips can be positioned at the top, bottom, left, or right of the trigger.
  def positions
    render_with_template
  end

  # Tooltip sizes
  # @label Sizes
  # @note
  #   Tooltips come in three sizes: small, medium (default), and large.
  def sizes
    render_with_template
  end

  # Without arrow
  # @label No Arrow
  # @note
  #   Tooltips can be rendered without the arrow indicator.
  def no_arrow
    render(Foundation::TooltipComponent.new(text: "Tooltip without arrow", arrow: false)) do
      tag.button("Hover me", type: "button", class: "px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700")
    end
  end

  # With delay
  # @label Custom Delay
  # @note
  #   The tooltip delay can be customized. This example has a 500ms delay.
  def with_delay
    render(Foundation::TooltipComponent.new(text: "I appear after 500ms", delay: 500)) do
      tag.button("Hover and wait", type: "button", class: "px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700")
    end
  end

  # With rich content
  # @label Rich Content
  # @note
  #   Tooltips can contain rich HTML content using the tooltip_content slot.
  def rich_content
    render_with_template
  end

  # On icon button
  # @label Icon Button
  # @note
  #   Tooltips are commonly used with icon-only buttons to provide context.
  def on_icon_button
    render_with_template
  end

  # In toolbar
  # @label Toolbar Example
  # @note
  #   Tooltips work well in toolbar contexts with multiple action buttons.
  def toolbar_example
    render_with_template
  end

  # Interactive playground
  # @label Playground
  # @param text text
  # @param position select { choices: [top, bottom, left, right] }
  # @param size select { choices: [small, medium, large] }
  # @param delay number
  # @param arrow toggle
  def playground(text: "Tooltip text", position: "top", size: "medium", delay: 200, arrow: true)
    render(Foundation::TooltipComponent.new(
      text: text,
      position: position.to_sym,
      size: size.to_sym,
      delay: delay.to_i,
      arrow: arrow
    )) do
      tag.button("Hover to preview", type: "button", class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700")
    end
  end
end
