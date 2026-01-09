# frozen_string_literal: true

# @label Display::Badge
# @note Displays status indicators, labels, or counts with various styles.
#   Use badges to highlight important information or categorize content.
class Display::BadgeComponentPreview < ViewComponent::Preview
  # @label Default (Subtle)
  # @note Use subtle badges for general labels and tags. This is the default variant
  #   with a light background and colored text.
  def default
    render(Display::BadgeComponent.new(text: "Default Badge"))
  end

  # @label Variants
  # @note Three visual styles: subtle (light background), solid (filled), and outline (bordered).
  #   Choose based on visual hierarchy and emphasis needed.
  def variants
    render_with_template(locals: {
      variants: [
        { variant: :subtle, label: "Subtle" },
        { variant: :solid, label: "Solid" },
        { variant: :outline, label: "Outline" }
      ]
    })
  end

  # @label Colors
  # @note Seven semantic colors available: neutral, primary, secondary, success, warning, danger, info.
  #   Use colors that match the meaning of your badge content.
  def colors
    render_with_template(locals: {
      colors: [
        { color: :neutral, label: "Neutral" },
        { color: :primary, label: "Primary" },
        { color: :secondary, label: "Secondary" },
        { color: :success, label: "Success" },
        { color: :warning, label: "Warning" },
        { color: :danger, label: "Danger" },
        { color: :info, label: "Info" }
      ]
    })
  end

  # @label Sizes
  # @note Three sizes available: small (default), medium, and large.
  #   Small is ideal for inline use, large for prominent status indicators.
  def sizes
    render_with_template(locals: {
      sizes: [
        { size: :small, label: "Small" },
        { size: :medium, label: "Medium" },
        { size: :large, label: "Large" }
      ]
    })
  end

  # @label Solid Variant
  # @note Solid badges with filled backgrounds. Best for high-contrast, prominent labels.
  def solid
    render_with_template(locals: {
      colors: [ :neutral, :primary, :secondary, :success, :warning, :danger, :info ]
    })
  end

  # @label Outline Variant
  # @note Outline badges with transparent backgrounds. Good for subtle indicators that
  #   don't overpower other content.
  def outline
    render_with_template(locals: {
      colors: [ :neutral, :primary, :secondary, :success, :warning, :danger, :info ]
    })
  end

  # @label Pill Shape
  # @note Set pill: true for fully rounded badges. Popular for tags and filters.
  def pill
    render_with_template(locals: {
      colors: [ :neutral, :primary, :success, :warning, :danger ]
    })
  end

  # @label With Icon
  # @note Add icons before badge text using the icon slot. Icons automatically resize
  #   based on badge size.
  def with_icon
    render_with_template(locals: {
      examples: [
        { text: "Verified", icon: "check-circle", color: :success },
        { text: "New", icon: "sparkles", color: :primary },
        { text: "Featured", icon: "star", color: :warning },
        { text: "Alert", icon: "exclamation-triangle", color: :danger },
        { text: "Info", icon: "information-circle", color: :info }
      ]
    })
  end

  # @label Dismissible
  # @note Add dismissible: true to show a remove button. Uses Stimulus controller
  #   for smooth scale-out animation.
  def dismissible
    render_with_template(locals: {
      tags: [ "Design", "Development", "Marketing", "Sales", "Support" ]
    })
  end

  # @label Status Indicators
  # @note Common use case: showing status of items, users, or processes.
  def status_indicators
    render_with_template(locals: {
      statuses: [
        { text: "Active", color: :success },
        { text: "Pending", color: :warning },
        { text: "Inactive", color: :neutral },
        { text: "Error", color: :danger },
        { text: "Processing", color: :info }
      ]
    })
  end

  # @label Counts
  # @note Badges work well for displaying counts, notifications, or metrics.
  def counts
    render_with_template(locals: {
      items: [
        { text: "3", color: :danger, label: "Unread" },
        { text: "12", color: :primary, label: "Messages" },
        { text: "99+", color: :success, label: "Followers" },
        { text: "5", color: :warning, label: "Pending" }
      ]
    })
  end

  # @label Tags
  # @note Use badges as removable tags for categories, filters, or selections.
  def tags
    render_with_template(locals: {
      tags: [
        { text: "Ruby", color: :danger },
        { text: "Rails", color: :danger },
        { text: "JavaScript", color: :warning },
        { text: "TypeScript", color: :primary },
        { text: "React", color: :info },
        { text: "Vue.js", color: :success }
      ]
    })
  end

  # @label Priority Levels
  # @note Use solid badges with semantic colors for priority or urgency indicators.
  def priority_levels
    render_with_template(locals: {
      priorities: [
        { text: "Critical", color: :danger, variant: :solid },
        { text: "High", color: :warning, variant: :solid },
        { text: "Medium", color: :primary, variant: :solid },
        { text: "Low", color: :neutral, variant: :solid }
      ]
    })
  end

  # @label User Roles
  # @note Example showing badges for user roles or permissions. Pill shape works well here.
  def user_roles
    render_with_template(locals: {
      roles: [
        { text: "Admin", color: :danger, icon: "shield-check" },
        { text: "Editor", color: :primary, icon: "pencil" },
        { text: "Author", color: :secondary, icon: "document-text" },
        { text: "Viewer", color: :neutral, icon: "eye" }
      ]
    })
  end

  # @label In Context
  # @note Badges used inline with text content, showing real-world usage.
  def in_context
    render_with_template
  end

  # @label Complete Example
  # @note Demonstrates badges with all features: icon, custom color, dismissible.
  def complete
    render(Display::BadgeComponent.new(
      text: "Premium Feature",
      variant: :solid,
      color: :secondary,
      size: :medium,
      pill: true,
      dismissible: true,
      id: "premium-badge"
    )) do |badge|
      badge.with_icon(name: "star", variant: :solid)
    end
  end

  # @label Playground
  # @note Interactive preview to test different badge configurations.
  # @param text text
  # @param variant select { choices: [subtle, solid, outline] }
  # @param color select { choices: [neutral, primary, secondary, success, warning, danger, info] }
  # @param size select { choices: [small, medium, large] }
  # @param pill toggle
  # @param dismissible toggle
  def playground(
    text: "Badge Text",
    variant: :subtle,
    color: :neutral,
    size: :small,
    pill: false,
    dismissible: false
  )
    render(Display::BadgeComponent.new(
      text: text,
      variant: variant.to_sym,
      color: color.to_sym,
      size: size.to_sym,
      pill: pill,
      dismissible: dismissible
    ))
  end
end
