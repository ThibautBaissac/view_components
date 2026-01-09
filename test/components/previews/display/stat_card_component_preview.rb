# frozen_string_literal: true

# @label Display::StatCard
# @note Displays key metrics and statistics in a visually appealing card format.
#   Use stat cards to present important numbers, KPIs, and performance indicators
#   on dashboards and overview pages. Supports icons, multiple colors, and sizes.
class Display::StatCardComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Simple stat card with just a value and descriptive label.
  #   The default style is centered with neutral colors, suitable for general metrics.
  def default
    render(Display::StatCardComponent.new(
      value: "€1,234",
      label: "Pending Commissions"
    ))
  end

  # @label With Icon
  # @note Add a Heroicon to visually represent the metric type.
  #   Icons help users quickly identify and scan different statistics.
  def with_icon
    render(Display::StatCardComponent.new(
      icon_name: "currency-dollar",
      value: "€5,678",
      label: "Total Revenue"
    ))
  end

  # @label Color Variants
  # @note Seven semantic colors for the value text: neutral (default), primary, secondary,
  #   success, warning, danger, and info. Choose colors that match the meaning of your metric.
  def color_variants
    render_with_template
  end

  # @label Size Variants
  # @note Four sizes available: default (compact), medium, large, and xlarge.
  #   Use larger sizes for hero metrics and smaller for secondary stats.
  def size_variants
    render_with_template
  end

  # @label Primary Color
  # @note Use primary color for brand-aligned metrics like user counts or engagement stats.
  def primary_color
    render(Display::StatCardComponent.new(
      icon_name: "users",
      value: "42",
      label: "Active Vendors",
      value_color: :primary
    ))
  end

  # @label Success Color
  # @note Use success (green) for positive metrics like completed tasks, revenue, or confirmations.
  def success_color
    render(Display::StatCardComponent.new(
      icon_name: "check-circle",
      value: "18",
      label: "Confirmed Events",
      value_color: :success
    ))
  end

  # @label Warning Color
  # @note Use warning (yellow/orange) for metrics requiring attention like pending items or approaching limits.
  def warning_color
    render(Display::StatCardComponent.new(
      icon_name: "exclamation-triangle",
      value: "€2,450",
      label: "Pending Payments",
      value_color: :warning
    ))
  end

  # @label Danger Color
  # @note Use danger (red) for critical issues, errors, or negative metrics that need immediate action.
  def danger_color
    render(Display::StatCardComponent.new(
      icon_name: "x-circle",
      value: "3",
      label: "Overdue Invoices",
      value_color: :danger
    ))
  end

  # @label Large Size
  # @note Large size increases padding and font sizes for prominent display.
  #   Ideal for hero metrics and key performance indicators on dashboards.
  def large_size
    render(Display::StatCardComponent.new(
      icon_name: "currency-euro",
      value: "€12,500",
      label: "Monthly Revenue",
      size: :large,
      value_color: :success
    ))
  end

  # @label XLarge Size
  # @note Extra-large size for the most important metrics that deserve maximum visual prominence.
  def xlarge_size
    render(Display::StatCardComponent.new(
      icon_name: "chart-bar",
      value: "156",
      label: "Total Events",
      size: :xlarge,
      value_color: :primary
    ))
  end

  # @label Left Aligned
  # @note Set centered: false to left-align content within the card.
  #   Useful for list-style layouts or when displaying multiple stats in a column.
  def left_aligned
    render(Display::StatCardComponent.new(
      icon_name: "building-storefront",
      value: "89",
      label: "Total Vendors",
      centered: false
    ))
  end

  # @label Dashboard Grid
  # @note Real-world example showing stat cards in a responsive grid layout.
  #   Demonstrates how to create an effective dashboard with multiple metrics.
  def dashboard_grid
    render_with_template
  end

  # @label With Custom Attributes
  # @note Pass custom HTML attributes like id, class, or data attributes for styling
  #   and JavaScript interactions (e.g., Stimulus controllers).
  def with_custom_attributes
    render(Display::StatCardComponent.new(
      icon_name: "calendar",
      value: "24",
      label: "Upcoming Events",
      value_color: :info,
      id: "upcoming-events-stat",
      class: "border-2 border-indigo-200"
    ))
  end

  # @label Icon Colors
  # @note Icons automatically match the value color for visual consistency.
  #   This example shows all available color combinations.
  def icon_colors
    render_with_template
  end

  # @label Responsive Grid
  # @note Stat cards adapt well to responsive layouts using Tailwind's grid utilities.
  #   This shows a mobile-friendly grid that stacks on small screens.
  def responsive_grid
    render_with_template
  end

  # @label Playground
  # @note Interactive preview to test different stat card configurations.
  # @param value text
  # @param label text
  # @param value_color select { choices: [neutral, primary, secondary, success, warning, danger, info] }
  # @param size select { choices: [default, medium, large, xlarge] }
  # @param centered toggle
  # @param icon_name text
  def playground(
    value: "42",
    label: "Active Users",
    value_color: :primary,
    size: :default,
    centered: true,
    icon_name: ""
  )
    render(Display::StatCardComponent.new(
      value: value,
      label: label,
      value_color: value_color.to_sym,
      size: size.to_sym,
      centered: centered,
      icon_name: icon_name.presence
    ))
  end
end
