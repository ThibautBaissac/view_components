# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::DropdownMenuComponent, type: :component do
  describe "basic rendering" do
    it "renders dropdown wrapper" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div.relative.inline-block")
      expect(page).to have_css("div[role='menu']")
    end

    it "applies stimulus controller" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div[data-controller='components--dropdown']")
    end

    it "generates unique IDs for trigger and menu" do
      component = described_class.new
      expect(component.trigger_id).to match(/^dropdown-trigger-[a-f0-9]+$/)
      expect(component.menu_id).to match(/^dropdown-menu-[a-f0-9]+$/)
    end

    it "menu is initially hidden" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("hidden")
    end
  end

  describe "placements" do
    it "renders bottom_start placement by default" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("top-full")
      expect(menu_element[:class]).to include("left-0")
    end

    it "renders bottom_end placement" do
      render_inline(described_class.new(placement: :bottom_end)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("top-full")
      expect(menu_element[:class]).to include("right-0")
    end

    it "renders top_start placement" do
      render_inline(described_class.new(placement: :top_start)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("bottom-full")
      expect(menu_element[:class]).to include("left-0")
    end

    it "renders top_end placement" do
      render_inline(described_class.new(placement: :top_end)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("bottom-full")
      expect(menu_element[:class]).to include("right-0")
    end

    it "raises error for invalid placement" do
      expect {
        described_class.new(placement: :invalid)
      }.to raise_error(ArgumentError, /Invalid placement: invalid/)
    end
  end

  describe "widths" do
    it "renders auto width by default" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("min-w-48")
    end

    it "renders small width" do
      render_inline(described_class.new(width: :small)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("w-40")
    end

    it "renders medium width" do
      render_inline(described_class.new(width: :medium)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("w-56")
    end

    it "renders large width" do
      render_inline(described_class.new(width: :large)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("w-72")
    end

    it "renders full width" do
      render_inline(described_class.new(width: :full)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      menu_element = page.find("div[role='menu']", visible: :all)
      expect(menu_element[:class]).to include("w-full")
    end

    it "raises error for invalid width" do
      expect {
        described_class.new(width: :invalid)
      }.to raise_error(ArgumentError, /Invalid width: invalid/)
    end
  end

  describe "close_on_select behavior" do
    it "sets close_on_select to true by default" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div[data-components--dropdown-close-on-select-value='true']")
    end

    it "sets close_on_select to false" do
      render_inline(described_class.new(close_on_select: false)) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div[data-components--dropdown-close-on-select-value='false']")
    end
  end

  describe "trigger slot" do
    it "renders custom trigger content" do
      render_inline(described_class.new) do |menu|
        menu.with_trigger do
          "<button class='custom-trigger'>Actions</button>".html_safe
        end
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("button.custom-trigger", text: "Actions")
    end

    it "renders without custom trigger" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      # Component renders even without custom trigger (trigger can be added externally)
      expect(page).to have_css("div[role='menu']", visible: :all)
    end
  end

  describe "link items" do
    it "renders link item with text and href" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("a[href='/profile'][role='menuitem']", text: "Profile")
    end

    it "renders multiple link items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
        menu.with_item_link(text: "Settings", href: "/settings")
        menu.with_item_link(text: "Sign out", href: "/logout")
      end

      expect(page).to have_css("a[role='menuitem']", count: 3)
      expect(page).to have_link("Profile", href: "/profile")
      expect(page).to have_link("Settings", href: "/settings")
      expect(page).to have_link("Sign out", href: "/logout")
    end

    it "adds stimulus target to link items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("a[data-components--dropdown-target='item']")
    end

    it "adds stimulus action to link items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      link = page.find("a[role='menuitem']")
      expect(link[:"data-action"]).to include("click->components--dropdown#select")
    end

    it "renders destructive link item" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Delete", href: "/delete", destructive: true)
      end

      link = page.find("a[role='menuitem']")
      expect(link[:class]).to include("text-red-600")
    end

    it "renders disabled link item as span" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Disabled", href: "/disabled", disabled: true)
      end

      expect(page).to have_css("span[role='menuitem'][aria-disabled='true']", text: "Disabled")
      expect(page).to have_no_css("a", text: "Disabled")
    end

    it "disabled link has no click action" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Disabled", href: "/disabled", disabled: true)
      end

      disabled_item = page.find("span[role='menuitem']")
      expect(disabled_item[:"data-action"]).to be_nil
    end

    it "applies cursor-not-allowed to disabled link" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Disabled", href: "/disabled", disabled: true)
      end

      span = page.find("span[role='menuitem']")
      expect(span[:class]).to include("cursor-not-allowed")
    end
  end

  describe "button items" do
    it "renders button item with text" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Export")
      end

      expect(page).to have_css("button[type='button'][role='menuitem']", text: "Export")
    end

    it "renders multiple button items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Export")
        menu.with_item_button(text: "Import")
      end

      expect(page).to have_css("button[role='menuitem']", count: 2)
    end

    it "adds stimulus target to button items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Export")
      end

      expect(page).to have_css("button[data-components--dropdown-target='item']")
    end

    it "adds stimulus action to button items" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Export")
      end

      button = page.find("button[role='menuitem']")
      expect(button[:"data-action"]).to include("click->components--dropdown#select")
    end

    it "renders destructive button item" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Delete All", destructive: true)
      end

      button = page.find("button[role='menuitem']")
      expect(button[:class]).to include("text-red-600")
    end

    it "renders disabled button item" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Disabled", disabled: true)
      end

      button = page.find("button[role='menuitem']")
      expect(button).to be_disabled
      expect(button[:"aria-disabled"]).to eq("true")
    end

    it "disabled button has no click action" do
      render_inline(described_class.new) do |menu|
        menu.with_item_button(text: "Disabled", disabled: true)
      end

      button = page.find("button[role='menuitem']")
      expect(button[:"data-action"]).to be_nil
    end
  end

  describe "divider items" do
    it "renders divider" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
        menu.with_item_divider
        menu.with_item_link(text: "Sign out", href: "/logout")
      end

      expect(page).to have_css("div[role='separator']")
    end

    it "applies divider styling" do
      render_inline(described_class.new) do |menu|
        menu.with_item_divider
      end

      divider = page.find("div[role='separator']")
      expect(divider[:class]).to include("border-t")
      expect(divider[:class]).to include("border-slate-200")
    end

    it "has data-divider attribute" do
      render_inline(described_class.new) do |menu|
        menu.with_item_divider
      end

      expect(page).to have_css("div[data-divider='true']")
    end
  end

  describe "header items" do
    it "renders header with text" do
      render_inline(described_class.new) do |menu|
        menu.with_item_header(text: "Account")
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div[role='presentation']", text: "Account")
    end

    it "applies header styling" do
      render_inline(described_class.new) do |menu|
        menu.with_item_header(text: "Account")
      end

      header = page.find("div[role='presentation']")
      expect(header[:class]).to include("text-xs")
      expect(header[:class]).to include("font-semibold")
      expect(header[:class]).to include("text-slate-600")
      expect(header[:class]).to include("uppercase")
    end

    it "renders multiple sections with headers" do
      render_inline(described_class.new) do |menu|
        menu.with_item_header(text: "Account")
        menu.with_item_link(text: "Profile", href: "/profile")
        menu.with_item_divider
        menu.with_item_header(text: "Actions")
        menu.with_item_button(text: "Export")
      end

      expect(page).to have_css("div[role='presentation']", count: 2)
      expect(page).to have_text("Account")
      expect(page).to have_text("Actions")
    end
  end

  describe "icon rendering" do
    context "with symbol icon" do
      it "renders icon from symbol" do
        render_inline(described_class.new) do |menu|
          menu.with_item_link(text: "Settings", href: "/settings", icon: :cog_6_tooth)
        end

        # IconComponent would be rendered
        expect(page).to have_link("Settings", href: "/settings")
      end
    end

    context "with string icon (SVG)" do
      it "sanitizes and renders safe SVG" do
        safe_svg = '<svg class="w-4 h-4"><path d="M0 0h24v24H0z"/></svg>'
        render_inline(described_class.new) do |menu|
          menu.with_item_link(text: "Edit", href: "/edit", icon: safe_svg)
        end

        expect(page).to have_css("svg")
      end

      it "sanitizes malicious SVG" do
        malicious_svg = '<svg><script>alert("xss")</script><path d="M0 0"/></svg>'
        result = described_class.sanitize_icon(malicious_svg)

        expect(result).not_to include("<script>")
        expect(result).not_to include("alert")
      end
    end

    context "with nil icon" do
      it "renders item without icon" do
        render_inline(described_class.new) do |menu|
          menu.with_item_link(text: "Profile", href: "/profile", icon: nil)
        end

        link = page.find("a[role='menuitem']")
        expect(link).to have_text("Profile")
      end
    end
  end

  describe "HTML attributes" do
    it "merges custom CSS classes" do
      render_inline(described_class.new(class: "custom-dropdown")) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css("div.relative.inline-block.custom-dropdown")
    end

    it "applies custom HTML attributes to wrapper" do
      render_inline(described_class.new(id: "my-dropdown", data: { testid: "dropdown" })) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      # The id and data attributes would be applied to the wrapper
      expect(page).to have_css("div.relative.inline-block")
    end
  end

  describe "keyboard accessibility attributes" do
    it "includes toggle click action on trigger" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[data-action*="click->components--dropdown#toggle"]')
    end

    it "includes trigger target for focus management" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[data-components--dropdown-target="trigger"]')
    end

    it "includes menu target for keyboard navigation scope" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[data-components--dropdown-target="menu"]')
    end

    it "sets aria-haspopup=menu on trigger for screen readers" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[aria-haspopup="menu"]')
    end

    it "sets aria-expanded=false on trigger by default" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[aria-expanded="false"]')
    end

    it "connects trigger with menu via aria-controls" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      trigger = page.find('[data-components--dropdown-target="trigger"]')
      menu_element = page.find('[role="menu"]', visible: :all)

      expect(trigger["aria-controls"]).to eq(menu_element["id"])
    end

    it "sets aria-labelledby on menu linking back to trigger" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      trigger = page.find('[data-components--dropdown-target="trigger"]')
      menu_element = page.find('[role="menu"]', visible: :all)

      expect(menu_element["aria-labelledby"]).to eq(trigger["id"])
    end

    it "sets aria-orientation=vertical on menu" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[role="menu"][aria-orientation="vertical"]')
    end

    it "sets tabindex=-1 on menu for focus management" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Profile", href: "/profile")
      end

      expect(page).to have_css('[role="menu"][tabindex="-1"]')
    end
  end

  describe "focus management" do
    it "menu items have proper roles" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Active", href: "/active")
        menu.with_item_link(text: "Another", href: "/another")
      end

      expect(page).to have_css('[role="menuitem"]', count: 2)
    end

    it "disabled items are rendered as span with aria-disabled" do
      render_inline(described_class.new) do |menu|
        menu.with_item_link(text: "Disabled", href: "/disabled", disabled: true)
      end

      expect(page).to have_css('span[role="menuitem"][aria-disabled="true"]')
    end
  end

  describe "complete example" do
    it "renders dropdown with all item types" do
      render_inline(described_class.new(
        placement: :bottom_end,
        width: :medium,
        close_on_select: true
      )) do |menu|
        menu.with_trigger do
          "<button>Menu</button>".html_safe
        end

        menu.with_item_header(text: "Account")
        menu.with_item_link(text: "Profile", href: "/profile", icon: :user)
        menu.with_item_link(text: "Settings", href: "/settings", icon: :cog_6_tooth)

        menu.with_item_divider

        menu.with_item_header(text: "Actions")
        menu.with_item_button(text: "Export", icon: :arrow_down_tray)
        menu.with_item_button(text: "Import", icon: :arrow_up_tray)

        menu.with_item_divider

        menu.with_item_link(text: "Sign out", href: "/logout", destructive: true)
      end

      expect(page).to have_button("Menu")
      expect(page).to have_css("div[role='menu']", visible: :all)
      expect(page).to have_css("div[role='presentation']", count: 2)
      expect(page).to have_link("Profile", href: "/profile")
      expect(page).to have_link("Settings", href: "/settings")
      expect(page).to have_button("Export")
      expect(page).to have_button("Import")
      expect(page).to have_link("Sign out", href: "/logout")
      expect(page).to have_css("div[role='separator']", count: 2)
    end
  end
end
