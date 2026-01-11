# frozen_string_literal: true

# @label Dropdown Menu
# @display bg_color "#f8fafc"
class Navigation::DropdownMenuComponentPreview < ViewComponent::Preview
  # Default dropdown menu with common options
  # @label Default
  def default
    render(Navigation::DropdownMenuComponent.new) do |menu|
      menu.with_item_link(text: "Profile", href: "#profile")
      menu.with_item_link(text: "Settings", href: "#settings")
      menu.with_item_divider
      menu.with_item_link(text: "Sign out", href: "#signout")
    end
  end

  # Dropdown with custom trigger button
  # @label Custom Trigger
  def with_custom_trigger
    render_with_template
  end

  # Dropdown with icons in menu items
  # @label With Icons
  def with_icons
    user_icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>'
    cog_icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>'
    logout_icon = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>'

    render(Navigation::DropdownMenuComponent.new) do |menu|
      menu.with_item_link(text: "Your Profile", href: "#profile", icon: user_icon)
      menu.with_item_link(text: "Settings", href: "#settings", icon: cog_icon)
      menu.with_item_divider
      menu.with_item_link(text: "Sign out", href: "#signout", icon: logout_icon)
    end
  end

  # Dropdown with section headers
  # @label With Headers
  def with_headers
    render(Navigation::DropdownMenuComponent.new(width: :medium)) do |menu|
      menu.with_item_header(text: "Account")
      menu.with_item_link(text: "Profile", href: "#profile")
      menu.with_item_link(text: "Billing", href: "#billing")
      menu.with_item_divider

      menu.with_item_header(text: "Team")
      menu.with_item_link(text: "Members", href: "#members")
      menu.with_item_link(text: "Invite", href: "#invite")
      menu.with_item_divider

      menu.with_item_header(text: "Danger Zone")
      menu.with_item_link(text: "Delete Account", href: "#delete", destructive: true)
    end
  end

  # Dropdown with button items for actions
  # @label With Buttons
  def with_buttons
    render(Navigation::DropdownMenuComponent.new) do |menu|
      menu.with_item_button(text: "Copy to clipboard")
      menu.with_item_button(text: "Export as PDF")
      menu.with_item_button(text: "Share via email")
      menu.with_item_divider
      menu.with_item_button(text: "Delete", destructive: true)
    end
  end

  # Dropdown with disabled items
  # @label With Disabled Items
  def with_disabled_items
    render(Navigation::DropdownMenuComponent.new) do |menu|
      menu.with_item_link(text: "Edit", href: "#edit")
      menu.with_item_link(text: "Duplicate", href: "#duplicate")
      menu.with_item_link(text: "Move to folder", href: "#move", disabled: true)
      menu.with_item_divider
      menu.with_item_button(text: "Archive", disabled: true)
      menu.with_item_link(text: "Delete", href: "#delete", destructive: true)
    end
  end

  # Dropdown with different placements
  # @label Placements
  def placements
    render_with_template
  end

  # Dropdown with different widths
  # @label Widths
  def widths
    render_with_template
  end

  # User account dropdown example
  # @label User Menu Example
  def user_menu_example
    render_with_template
  end

  # Destructive actions dropdown
  # @label Destructive Actions
  def destructive_actions
    render_with_template
  end

  # Complex menu with all features
  # @label Complete Example
  def complete_example
    render_with_template
  end
end
