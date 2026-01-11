# frozen_string_literal: true

# @label Icon
# @logical_path Foundation
class Foundation::IconComponentPreview < ViewComponent::Preview
  # @label Default (Outline)
  # @note
  #   The default icon component renders Heroicon outline icons
  #   at medium size with the current text color.
  def default
    render(Foundation::IconComponent.new(name: "check"))
  end

  # @label Icon Sizes
  # @note
  #   Icons are available in 6 sizes: xs, small, medium (default), large, xl, and xxl.
  def sizes
    render_with_template
  end

  # @label Icon Variants
  # @note
  #   Heroicons come in four variants:
  #   - **outline** (default): 24x24 stroke icons
  #   - **solid**: 24x24 filled icons
  #   - **mini**: 20x20 solid icons optimized for smaller sizes
  #   - **micro**: 16x16 solid icons optimized for tight UI spaces
  def variants
    render_with_template
  end

  # @label Icon Colors
  # @note
  #   Icons support semantic colors: current, primary, secondary, success, warning, danger, info, muted, white, and black.
  def colors
    render_with_template
  end

  # @label Common Icons Gallery
  # @note
  #   A gallery of commonly used icons with their names.
  def gallery
    render_with_template
  end

  # @label Accessible Icon
  # @note
  #   When an icon conveys meaning, add a `label` attribute to make it accessible to screen readers.
  def accessible
    render(Foundation::IconComponent.new(
      name: "check-circle",
      color: :success,
      label: "Success checkmark"
    ))
  end

  # @label Icon in Button
  # @note
  #   Icons can be combined with text in buttons and other interactive elements.
  def in_button
    render_with_template
  end

  # @label Icon List
  # @note
  #   Icons work well in lists and navigation items.
  def in_list
    render_with_template
  end

  # @label Status Indicators
  # @note
  #   Using icons with colors as status indicators.
  def status_indicators
    render_with_template
  end

  # @label Mini Variant (20x20)
  # @note
  #   The **mini** variant is optimized for 20x20 icons, perfect for compact UI elements
  #   like inline buttons, small badges, and tight layouts.
  def mini_variant
    render_with_template
  end

  # @label Micro Variant (16x16)
  # @note
  #   The **micro** variant is optimized for 16x16 icons, ideal for dense interfaces,
  #   inline text icons, and space-constrained designs.
  def micro_variant
    render_with_template
  end

  # @label Variant Size Comparison
  # @note
  #   Side-by-side comparison of all four variants at their recommended sizes.
  def variant_comparison
    render_with_template
  end

  # @label Dynamic Icon
  # @param name select { choices: [check, x-mark, user, bell, trash, pencil-square, magnifying-glass, cog-6-tooth, envelope, bars-3] }
  # @param variant select { choices: [outline, solid, mini, micro] }
  # @param size select { choices: [xs, small, medium, large, xl, xxl] }
  # @param color select { choices: [current, primary, secondary, success, warning, danger, info, muted] }
  def dynamic(name: "check", variant: "outline", size: "medium", color: "current")
    render(Foundation::IconComponent.new(
      name: name,
      variant: variant.to_sym,
      size: size.to_sym,
      color: color.to_sym
    ))
  end
end
