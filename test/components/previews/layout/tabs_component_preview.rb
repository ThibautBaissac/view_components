# frozen_string_literal: true

# @label Layout::Tabs
# @note An accessible tabbed interface component that organizes content into multiple panels.
#   Uses WAI-ARIA best practices for keyboard navigation and screen reader support.
class Layout::TabsComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic tabs with underline variant (default). Use arrow keys to navigate.
  def default
    render(Layout::TabsComponent.new) do |tabs|
      tabs.with_tab(id: "overview", label: "Overview", selected: true) do
        content_tag(:div, class: "space-y-4") do
          safe_join([
            content_tag(:h3, "Welcome to the Overview", class: "text-lg font-semibold text-gray-900"),
            content_tag(:p, "This is the overview panel content. Click on other tabs to see more content.", class: "text-gray-600")
          ])
        end
      end

      tabs.with_tab(id: "features", label: "Features") do
        content_tag(:div, class: "space-y-4") do
          safe_join([
            content_tag(:h3, "Product Features", class: "text-lg font-semibold text-gray-900"),
            content_tag(:ul, class: "list-disc list-inside text-gray-600 space-y-2") do
              safe_join([
                content_tag(:li, "Accessible keyboard navigation"),
                content_tag(:li, "Multiple visual variants"),
                content_tag(:li, "Icon support"),
                content_tag(:li, "Vertical and horizontal layouts")
              ])
            end
          ])
        end
      end

      tabs.with_tab(id: "pricing", label: "Pricing") do
        content_tag(:p, "Pricing information goes here.", class: "text-gray-600")
      end
    end
  end

  # @label Pills Variant
  # @note Tabs styled as rounded pills for a more modern look.
  def pills
    render(Layout::TabsComponent.new(variant: :pills)) do |tabs|
      tabs.with_tab(id: "all", label: "All Items", selected: true) do
        content_tag(:p, "Showing all items in this category.", class: "text-gray-600")
      end

      tabs.with_tab(id: "active", label: "Active") do
        content_tag(:p, "Showing only active items.", class: "text-gray-600")
      end

      tabs.with_tab(id: "archived", label: "Archived") do
        content_tag(:p, "Showing archived items.", class: "text-gray-600")
      end
    end
  end

  # @label Boxed Variant
  # @note Tabs with a boxed card-like appearance.
  def boxed
    render(Layout::TabsComponent.new(variant: :boxed)) do |tabs|
      tabs.with_tab(id: "details", label: "Details", selected: true) do
        content_tag(:p, "Product details panel.", class: "text-gray-600")
      end

      tabs.with_tab(id: "specs", label: "Specifications") do
        content_tag(:p, "Technical specifications panel.", class: "text-gray-600")
      end

      tabs.with_tab(id: "reviews", label: "Reviews") do
        content_tag(:p, "Customer reviews panel.", class: "text-gray-600")
      end
    end
  end

  # @label With Icons
  # @note Tabs with icons for visual enhancement.
  def with_icons
    render(Layout::TabsComponent.new) do |tabs|
      tabs.with_tab(id: "home", label: "Home", icon: :home, selected: true) do
        content_tag(:p, "Welcome home!", class: "text-gray-600")
      end

      tabs.with_tab(id: "user", label: "Profile", icon: :user) do
        content_tag(:p, "Your profile information.", class: "text-gray-600")
      end

      tabs.with_tab(id: "settings", label: "Settings", icon: :cog_6_tooth) do
        content_tag(:p, "Application settings.", class: "text-gray-600")
      end
    end
  end

  # @label Full Width
  # @note Tabs that stretch to fill the available width.
  def full_width
    render(Layout::TabsComponent.new(full_width: true)) do |tabs|
      tabs.with_tab(id: "tab1", label: "First Tab", selected: true) do
        content_tag(:p, "First tab content.", class: "text-gray-600")
      end

      tabs.with_tab(id: "tab2", label: "Second Tab") do
        content_tag(:p, "Second tab content.", class: "text-gray-600")
      end

      tabs.with_tab(id: "tab3", label: "Third Tab") do
        content_tag(:p, "Third tab content.", class: "text-gray-600")
      end
    end
  end

  # @label Vertical Tabs
  # @note Tabs arranged vertically for sidebar-style navigation.
  def vertical
    render(Layout::TabsComponent.new(vertical: true)) do |tabs|
      tabs.with_tab(id: "general", label: "General", selected: true) do
        content_tag(:div, class: "space-y-4") do
          safe_join([
            content_tag(:h3, "General Settings", class: "text-lg font-semibold text-gray-900"),
            content_tag(:p, "Configure general application settings here.", class: "text-gray-600")
          ])
        end
      end

      tabs.with_tab(id: "security", label: "Security") do
        content_tag(:div, class: "space-y-4") do
          safe_join([
            content_tag(:h3, "Security Settings", class: "text-lg font-semibold text-gray-900"),
            content_tag(:p, "Manage your security preferences.", class: "text-gray-600")
          ])
        end
      end

      tabs.with_tab(id: "notifications", label: "Notifications") do
        content_tag(:div, class: "space-y-4") do
          safe_join([
            content_tag(:h3, "Notification Preferences", class: "text-lg font-semibold text-gray-900"),
            content_tag(:p, "Choose how you want to be notified.", class: "text-gray-600")
          ])
        end
      end

      tabs.with_tab(id: "integrations", label: "Integrations") do
        content_tag(:p, "Connect with third-party services.", class: "text-gray-600")
      end
    end
  end

  # @label With Disabled Tab
  # @note Demonstrates a tab that cannot be selected.
  def with_disabled
    render(Layout::TabsComponent.new) do |tabs|
      tabs.with_tab(id: "available", label: "Available", selected: true) do
        content_tag(:p, "This content is available.", class: "text-gray-600")
      end

      tabs.with_tab(id: "restricted", label: "Restricted", disabled: true) do
        content_tag(:p, "This content is restricted.", class: "text-gray-600")
      end

      tabs.with_tab(id: "other", label: "Other") do
        content_tag(:p, "Other available content.", class: "text-gray-600")
      end
    end
  end

  # @label Pre-selected Tab
  # @note Demonstrates selecting a tab other than the first one by default.
  def preselected
    render(Layout::TabsComponent.new) do |tabs|
      tabs.with_tab(id: "draft", label: "Draft") do
        content_tag(:p, "Draft items.", class: "text-gray-600")
      end

      tabs.with_tab(id: "published", label: "Published", selected: true) do
        content_tag(:p, "Published items are shown here by default.", class: "text-gray-600")
      end

      tabs.with_tab(id: "scheduled", label: "Scheduled") do
        content_tag(:p, "Scheduled items.", class: "text-gray-600")
      end
    end
  end

  # @label Pills Full Width
  # @note Pills variant with full width tabs.
  def pills_full_width
    render(Layout::TabsComponent.new(variant: :pills, full_width: true)) do |tabs|
      tabs.with_tab(id: "week", label: "Week", selected: true) do
        content_tag(:p, "Weekly view.", class: "text-gray-600")
      end

      tabs.with_tab(id: "month", label: "Month") do
        content_tag(:p, "Monthly view.", class: "text-gray-600")
      end

      tabs.with_tab(id: "year", label: "Year") do
        content_tag(:p, "Yearly view.", class: "text-gray-600")
      end
    end
  end

  # @label Vertical Pills
  # @note Vertical tabs with pills variant.
  def vertical_pills
    render(Layout::TabsComponent.new(variant: :pills, vertical: true)) do |tabs|
      tabs.with_tab(id: "account", label: "Account", selected: true) do
        content_tag(:p, "Account settings.", class: "text-gray-600")
      end

      tabs.with_tab(id: "billing", label: "Billing") do
        content_tag(:p, "Billing information.", class: "text-gray-600")
      end

      tabs.with_tab(id: "team", label: "Team") do
        content_tag(:p, "Team management.", class: "text-gray-600")
      end
    end
  end
end
