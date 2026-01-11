# frozen_string_literal: true

# Foundation::DividerComponentPreview
#
# Lookbook preview for demonstrating Foundation::DividerComponent variations
class Foundation::DividerComponentPreview < ViewComponent::Preview
  # Default horizontal divider
  # @label Default
  def default
    render(Foundation::DividerComponent.new)
  end

  # Horizontal divider with different thicknesses
  # @label Thicknesses
  def thicknesses
    render_with_template
  end

  # Dividers with different colors
  # @label Colors
  def colors
    render_with_template
  end

  # Dividers with different spacing
  # @label Spacing
  def spacing
    render_with_template
  end

  # Vertical divider for sidebars/toolbars
  # @label Vertical
  def vertical
    render_with_template
  end

  # Divider with label (horizontal)
  # @label With Label
  def with_label
    render(Foundation::DividerComponent.new(spacing: :medium)) { "OR" }
  end

  # Divider with label in login form context
  # @label Login Form
  def login_form
    render_with_template
  end

  # Vertical divider with label
  # @label Vertical with Label
  def vertical_with_label
    render_with_template
  end

  # Thin muted divider (subtle)
  # @label Subtle
  def subtle
    render(Foundation::DividerComponent.new(
      thickness: :hairline,
      color: :muted,
      spacing: :small
    ))
  end

  # Thick primary divider (emphasis)
  # @label Emphasis
  def emphasis
    render(Foundation::DividerComponent.new(
      thickness: :thick,
      color: :primary,
      spacing: :large
    ))
  end

  # Danger divider for warnings
  # @label Danger
  def danger
    render(Foundation::DividerComponent.new(
      thickness: :medium,
      color: :danger,
      spacing: :medium
    ))
  end

  # Success divider
  # @label Success
  def success
    render(Foundation::DividerComponent.new(
      thickness: :thin,
      color: :success,
      spacing: :medium
    ))
  end

  # Toolbar with vertical dividers
  # @label Toolbar Example
  def toolbar_example
    render_with_template
  end

  # Content sections with dividers
  # @label Content Sections
  def content_sections
    render_with_template
  end

  # Dynamic parameters from URL
  # @label Playground
  # @note Interactive preview to test different divider configurations.
  # @param orientation select { choices: [horizontal, vertical] }
  # @param thickness select { choices: [hairline, thin, medium, thick] }
  # @param color select { choices: [default, muted, primary, secondary, success, warning, danger] }
  # @param spacing select { choices: [none, small, medium, large, xlarge] }
  def playground(
    orientation: :horizontal,
    thickness: :hairline,
    color: :default,
    spacing: :medium
  )
    render(Foundation::DividerComponent.new(
      orientation: orientation.to_sym,
      thickness: thickness.to_sym,
      color: color.to_sym,
      spacing: spacing.to_sym
    ))
  end
end
