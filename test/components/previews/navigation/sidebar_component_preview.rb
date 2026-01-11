# frozen_string_literal: true

# @label Navigation::Sidebar
# @logical_path Navigation
# @display bg_color "#f3f4f6"
# @note A flexible, collapsible sidebar navigation component for application layouts.
#   Supports navigation items, sections, badges, user profiles, logos, and footer content.
#   Integrates with LanguageSwitcherComponent and provides mobile-responsive behavior.
class Navigation::SidebarComponentPreview < ViewComponent::Preview
  # @label Default
  # @note Basic sidebar with logo text and navigation items. Shows active state highlighting
  #   and icon integration. This is the minimum configuration for a functional sidebar.
  def default
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS")) do |component|
      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Projects", href: "#", icon: "folder")
      component.with_nav_item(text: "Calendar", href: "#", icon: "calendar")
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")
    end
  end

  # @label With Sections
  # @note Organize navigation items into collapsible sections with titles.
  #   Sections help group related navigation items for better information architecture.
  def with_sections
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS")) do |component|
      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)

      component.with_nav_section(title: "Projects") do |section|
        section.with_item(text: "All Projects", href: "#", icon: "folder")
        section.with_item(text: "My Projects", href: "#", icon: "user")
        section.with_item(text: "Shared", href: "#", icon: "users")
      end

      component.with_nav_section(title: "Settings") do |section|
        section.with_item(text: "Profile", href: "#", icon: "user-circle")
        section.with_item(text: "Billing", href: "#", icon: "credit-card")
        section.with_item(text: "Notifications", href: "#", icon: "bell")
      end
    end
  end

  # @label With Badges
  # @note Add notification badges to navigation items to highlight unread counts,
  #   pending tasks, or other metrics that require user attention.
  def with_badges
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS")) do |component|
      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Messages", href: "#", icon: "envelope", badge: "12")
      component.with_nav_item(text: "Notifications", href: "#", icon: "bell", badge: "3")
      component.with_nav_item(text: "Tasks", href: "#", icon: "check-circle", badge: "5")
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")
    end
  end

  # @label With User Profile
  # @note Display user information at the top of the sidebar using the user_profile slot.
  #   Commonly includes avatar, name, and email. Clickable for profile or account settings.
  def with_user_profile
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS")) do |component|
      component.with_user_profile do
        <<~HTML.html_safe
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white font-semibold">
              JD
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">John Doe</p>
              <p class="text-xs text-gray-500 truncate">john@example.com</p>
            </div>
          </div>
        HTML
      end

      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Projects", href: "#", icon: "folder")
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")
    end
  end

  # @label Complete
  # @note Comprehensive example demonstrating all available features: user profile, sections,
  #   badges, language switcher, footer content, and sticky positioning. Use as a reference
  #   for building feature-rich application sidebars.
  def complete
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS", sticky: true)) do |component|
      # User Profile
      component.with_user_profile do
        <<~HTML.html_safe
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-semibold">
              JD
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">John Doe</p>
              <p class="text-xs text-gray-500 truncate">Premium Plan</p>
            </div>
          </div>
        HTML
      end

      # Main Navigation
      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Messages", href: "#", icon: "envelope", badge: "5")

      # Projects Section
      component.with_nav_section(title: "Projects") do |section|
        section.with_item(text: "All Projects", href: "#", icon: "folder")
        section.with_item(text: "Favorites", href: "#", icon: "star")
        section.with_item(text: "Archive", href: "#", icon: "archive")
      end

      # Team Section
      component.with_nav_section(title: "Team") do |section|
        section.with_item(text: "Members", href: "#", icon: "users")
        section.with_item(text: "Invitations", href: "#", icon: "user-plus", badge: "2")
        section.with_item(text: "Activity", href: "#", icon: "clock")
      end

      # Settings
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")

      # Language Switcher
      component.with_language_switcher

      # Footer Content
      component.with_footer_content do
        <<~HTML.html_safe
          <div class="space-y-2">
            <div class="flex items-center justify-between text-xs text-gray-500">
              <span>Version 1.0.0</span>
              <a href="#" class="text-blue-600 hover:text-blue-700">Help</a>
            </div>
            <p class="text-xs text-gray-400">© 2024 CraftOS</p>
          </div>
        HTML
      end
    end
  end

  # @label Custom Logo
  # @note Replace the simple logo text with a custom logo slot for branding.
  #   You can include images, gradients, or any HTML for rich brand presentation.
  def with_custom_logo
    render(Navigation::SidebarComponent.new) do |component|
      component.with_logo(href: "#") do
        <<~HTML.html_safe
          <div class="flex items-center gap-2">
            <div class="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg"></div>
            <span class="text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              CraftOS
            </span>
          </div>
        HTML
      end

      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Projects", href: "#", icon: "folder", badge: "12")
      component.with_nav_item(text: "Team", href: "#", icon: "users")
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")
    end
  end

  # @label Minimal
  # @note Simplest possible sidebar with just navigation items and no logo or extras.
  #   Ideal for admin panels or utility applications where branding is minimal.
  def minimal
    render(Navigation::SidebarComponent.new) do |component|
      component.with_nav_item(text: "Home", href: "#", active: true)
      component.with_nav_item(text: "About", href: "#")
      component.with_nav_item(text: "Contact", href: "#")
    end
  end

  # @label Text Only
  # @note Navigation items without icons for a cleaner, text-focused design.
  #   Useful when navigation is self-explanatory or space is at a premium.
  def text_only
    render(Navigation::SidebarComponent.new(logo_text: "MyApp")) do |component|
      component.with_nav_item(text: "Dashboard", href: "#", active: true)
      component.with_nav_item(text: "Analytics", href: "#")
      component.with_nav_item(text: "Reports", href: "#")
      component.with_nav_item(text: "Team", href: "#")
      component.with_nav_item(text: "Settings", href: "#")
    end
  end

  # @label Non-Sticky
  # @note Set sticky: false to allow the sidebar to scroll with page content instead of
  #   remaining fixed in the viewport. Default is sticky (fixed positioning).
  def non_sticky
    render(Navigation::SidebarComponent.new(logo_text: "CraftOS", sticky: false)) do |component|
      component.with_nav_item(text: "Dashboard", href: "#", icon: "home", active: true)
      component.with_nav_item(text: "Projects", href: "#", icon: "folder")
      component.with_nav_item(text: "Settings", href: "#", icon: "cog")
    end
  end
end
