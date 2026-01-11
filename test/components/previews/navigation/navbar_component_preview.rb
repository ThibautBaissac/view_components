# frozen_string_literal: true

class Navigation::NavbarComponentPreview < ViewComponent::Preview
  # Basic navbar with logo and navigation items
  # @label Default
  def default
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")
    end
  end

  # Navbar with action button
  # @label With Action
  def with_action
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")

      navbar.with_action do
        tag.button("Sign Out", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # Navbar with multiple actions
  # @label Multiple Actions
  def multiple_actions
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#")
      navbar.with_nav_item(text: "Events", url: "#", active: true)
      navbar.with_nav_item(text: "Vendors", url: "#")

      navbar.with_action do
        tag.button("Help", class: "px-3 py-2 text-sm text-slate-700 hover:text-slate-900")
      end

      navbar.with_action do
        tag.button("Sign Out", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # Dark variant navbar
  # @label Dark Variant
  def dark_variant
    render(Navigation::NavbarComponent.new(variant: :dark)) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-white") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")

      navbar.with_action do
        tag.button("Sign Out", class: "px-4 py-2 bg-white text-gray-900 rounded-lg text-sm font-medium hover:bg-gray-100")
      end
    end
  end

  # Transparent variant navbar
  # @label Transparent Variant
  def transparent_variant
    render_with_template
  end

  # Sticky navbar
  # @label Sticky
  def sticky
    render_with_template
  end

  # Navbar with logo image
  # @label With Logo Image
  def with_logo_image
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "flex items-center gap-2") do
          tag.div(class: "w-8 h-8 bg-indigo-600 rounded-lg") +
          tag.span("EventEssentials", class: "font-bold text-xl text-slate-900")
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")
    end
  end

  # Full featured navbar
  # @label Full Featured
  def full_featured
    render(Navigation::NavbarComponent.new(sticky: true)) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "flex items-center gap-2") do
          tag.div(class: "w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center") do
            tag.span("EE", class: "text-white font-bold text-sm")
          end +
          tag.span("EventEssentials", class: "font-bold text-xl text-slate-900")
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")
      navbar.with_nav_item(text: "Reports", url: "#")

      navbar.with_action do
        tag.div(class: "flex items-center gap-2") do
          tag.span("John Doe", class: "text-sm text-slate-700")
        end
      end

      navbar.with_action do
        tag.button("Sign Out", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # French language example
  # @label French Example
  def french_example
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Tableau de bord", url: "#", active: true)
      navbar.with_nav_item(text: "Événements", url: "#")
      navbar.with_nav_item(text: "Prestataires", url: "#")
      navbar.with_nav_item(text: "Rapports", url: "#")

      navbar.with_action do
        tag.button("Déconnexion", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # Navbar without logo
  # @label Without Logo
  def without_logo
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)
      navbar.with_nav_item(text: "Events", url: "#")
      navbar.with_nav_item(text: "Vendors", url: "#")

      navbar.with_action do
        tag.button("Sign Out", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # Minimal navbar
  # @label Minimal
  def minimal
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Home", url: "#", active: true)
      navbar.with_nav_item(text: "About", url: "#")
    end
  end

  # Navbar variants comparison
  # @label Variants Comparison
  def variants_comparison
    render_with_template
  end

  # Loading state navbar (skeleton)
  # @label Loading State
  def loading_state
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.div(class: "h-6 w-40 bg-slate-200 rounded animate-pulse")
      end

      # Skeleton nav items
      navbar.with_nav_item(text: "        ", url: "#") # Placeholder
      navbar.with_nav_item(text: "        ", url: "#") # Placeholder
      navbar.with_nav_item(text: "        ", url: "#") # Placeholder

      navbar.with_action do
        tag.div(class: "h-9 w-24 bg-slate-200 rounded animate-pulse")
      end
    end
  end

  # Empty state (no navigation items - logged out)
  # @label Empty State
  def empty_state
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-indigo-600") do
          "EventEssentials"
        end
      end

      navbar.with_action do
        tag.button("Sign In", class: "px-4 py-2 bg-indigo-600 text-white rounded-lg text-sm font-medium hover:bg-indigo-700")
      end
    end
  end

  # Error state with notification
  # @label Error State
  def error_state
    render(Navigation::NavbarComponent.new) do |navbar|
      navbar.with_logo do
        tag.a(href: "#", class: "font-bold text-xl text-red-600") do
          "EventEssentials"
        end
      end

      navbar.with_nav_item(text: "Dashboard", url: "#", active: true)

      navbar.with_action do
        tag.div(class: "flex items-center gap-2") do
          tag.span("⚠", class: "text-red-600") +
          tag.span("Error loading data", class: "text-sm text-red-600 font-medium")
        end
      end
    end
  end
end
