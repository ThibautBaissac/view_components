# frozen_string_literal: true

# @label Foundation::Spinner
# @logical_path Foundation
# @note Displays an animated loading spinner to indicate ongoing operations.
#   Use spinners for loading states, async operations, and processing feedback.
#   Supports multiple sizes, colors, labels, and positioning options. WCAG 2.1 AA compliant
#   with proper ARIA attributes for screen reader accessibility.
class Foundation::SpinnerComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic spinner with default medium size and primary color.
  #   Includes proper ARIA attributes for accessibility without visible text.
  def default
    render(Foundation::SpinnerComponent.new)
  end

  # @label With Label
  # @note Add descriptive text below the spinner to provide context about the loading operation.
  #   Labels are especially helpful for longer operations or when the user needs reassurance.
  def with_label
    render(Foundation::SpinnerComponent.new(label: "Chargement..."))
  end

  # @label All Sizes
  # @note Five sizes available: xs, small, medium (default), large, and xl.
  #   Choose size based on context - xs for inline buttons, xl for full-page loading.
  def all_sizes
    render_with_template
  end

  # @label All Colors
  # @note Seven semantic colors available to match your UI context and brand.
  #   White is particularly useful for spinners on dark or colored backgrounds.
  def all_colors
    render_with_template
  end

  # @label XS Size
  # @note Extra-small spinner (16px) perfect for inline use within buttons or compact UI elements.
  def xs_size
    render(Foundation::SpinnerComponent.new(size: :xs, label: "Chargement"))
  end

  # @label Small Size
  # @note Small spinner (20px) suitable for inline loading indicators and small buttons.
  def small_size
    render(Foundation::SpinnerComponent.new(size: :small, label: "Chargement"))
  end

  # @label Medium Size
  # @note Medium spinner (24px) is the default size, balanced for most use cases.
  def medium_size
    render(Foundation::SpinnerComponent.new(size: :medium, label: "Chargement"))
  end

  # @label Large Size
  # @note Large spinner (32px) for prominent loading states and section loading indicators.
  def large_size
    render(Foundation::SpinnerComponent.new(size: :large, label: "Chargement"))
  end

  # @label XL Size
  # @note Extra-large spinner (48px) ideal for full-page loading overlays and initial app load states.
  def xl_size
    render(Foundation::SpinnerComponent.new(size: :xl, label: "Chargement"))
  end

  # @label Centered
  # @note Set centered: true to center the spinner horizontally within its container.
  #   Useful for loading states that occupy the full width of a section or page.
  def centered
    render(Foundation::SpinnerComponent.new(
      centered: true,
      label: "Chargement des données...",
      size: :large
    ))
  end

  # @label Inline
  # @note Set inline: true to display the spinner inline with text, commonly used in buttons
  #   during form submission or async actions. Uses inline-flex for proper alignment.
  def inline
    render_with_template
  end

  # @label Primary Color
  # @note Primary brand color spinner for general loading states that align with your brand.
  def primary_color
    render(Foundation::SpinnerComponent.new(
      color: :primary,
      label: "Chargement",
      size: :large
    ))
  end

  # @label Success Color
  # @note Success (green) spinner for operations with positive connotations like saving or processing.
  def success_color
    render(Foundation::SpinnerComponent.new(
      color: :success,
      label: "Traitement",
      size: :large
    ))
  end

  # @label Danger Color
  # @note Danger (red) spinner for destructive operations like deletion or critical processing.
  def danger_color
    render(Foundation::SpinnerComponent.new(
      color: :danger,
      label: "Suppression",
      size: :large
    ))
  end

  # @label White Color
  # @note White spinner for use on dark or colored backgrounds. Essential for dark mode support.
  def white_color
    render_with_template
  end

  # @label In Button
  # @note Real-world example showing spinner integration within button loading states.
  #   Demonstrates proper sizing and alignment for inline button spinners.
  def in_button
    render_with_template
  end

  # @label Full Page Loading
  # @note Example of a full-page loading overlay with centered XL spinner and descriptive text.
  #   Useful for initial app load, authentication, or major data fetching operations.
  def full_page_loading
    render_with_template
  end

  # @label Custom ARIA Label
  # @note Provide a custom aria_label for screen readers to describe the specific loading operation.
  #   This improves accessibility by giving blind users context about what's happening.
  def custom_aria_label
    render(Foundation::SpinnerComponent.new(
      aria_label: "Enregistrement de vos modifications",
      label: "Enregistrement..."
    ))
  end

  # @label Sizes Comparison
  # @note Visual comparison of all five spinner sizes to help choose the right one for your use case.
  def sizes_comparison
    render_with_template
  end

  # @label Playground
  # @note Interactive preview to test different spinner configurations in real-time.
  #   Experiment with size, color, positioning, and label combinations.
  # @param size select [xs, small, medium, large, xl] "Size"
  # @param color select [primary, secondary, success, danger, warning, info, white] "Color"
  # @param centered toggle "Centered"
  # @param inline toggle "Inline"
  # @param label text "Label"
  def playground(size: "medium", color: "primary", centered: false, inline: false, label: "")
    render(Foundation::SpinnerComponent.new(
      size: size.to_sym,
      color: color.to_sym,
      centered: centered,
      inline: inline,
      label: label.presence
    ))
  end
end
