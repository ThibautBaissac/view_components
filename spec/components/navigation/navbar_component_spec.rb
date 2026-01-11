# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::NavbarComponent, type: :component do
  describe "rendering" do
    context "with minimal parameters" do
      it "renders the navbar" do
        render_inline(described_class.new)

        expect(page).to have_css("nav[data-controller='components--navbar']")
      end

      it "renders the mobile menu button" do
        render_inline(described_class.new)

        expect(page).to have_css("button[data-action='click->components--navbar#toggleMenu']")
        expect(page).to have_css("svg[data-components--navbar-target='menuIcon']")
        expect(page).to have_css("svg[data-components--navbar-target='closeIcon']")
      end

      it "renders mobile menu with hidden state" do
        render_inline(described_class.new)

        expect(page).to have_css("div[data-components--navbar-target='menu'].hidden")
      end
    end

    context "with variant: :default" do
      it "applies default variant classes" do
        render_inline(described_class.new(variant: :default))

        expect(page).to have_css("nav.bg-white.text-gray-900")
      end
    end

    context "with variant: :dark" do
      it "applies dark variant classes" do
        render_inline(described_class.new(variant: :dark))

        expect(page).to have_css("nav.bg-gray-900.text-white")
      end
    end

    context "with variant: :transparent" do
      it "applies transparent variant classes" do
        render_inline(described_class.new(variant: :transparent))

        expect(page).to have_css("nav.bg-transparent")
      end
    end

    context "with sticky: true" do
      it "adds sticky positioning classes" do
        render_inline(described_class.new(sticky: true))

        expect(page).to have_css("nav.sticky.top-0.z-50")
      end
    end

    context "with custom HTML attributes" do
      it "merges custom attributes" do
        render_inline(described_class.new(id: "custom-navbar", data: { testid: "navbar" }))

        expect(page).to have_css("nav#custom-navbar[data-testid='navbar']")
      end
    end
  end

  describe "slots" do
    context "with logo slot" do
      it "renders the logo content" do
        render_inline(described_class.new) do |component|
          component.with_logo do
            "<a href='/' class='font-bold'>EventEssentials</a>".html_safe
          end
        end

        expect(page).to have_link("EventEssentials", href: "/")
      end
    end

    context "without logo slot" do
      it "does not render logo section with content" do
        render_inline(described_class.new)

        expect(page).to have_css(".flex-shrink-0")
        expect(page).not_to have_link
      end
    end

    context "with nav_items slot" do
      it "renders single nav item" do
        render_inline(described_class.new) do |component|
          component.with_nav_item(text: "Dashboard", url: "/dashboard")
        end

        expect(page).to have_link("Dashboard", href: "/dashboard")
        expect(page).to have_css("a.px-3.py-2.rounded-md")
      end

      it "renders multiple nav items" do
        render_inline(described_class.new) do |component|
          component.with_nav_item(text: "Dashboard", url: "/dashboard")
          component.with_nav_item(text: "Events", url: "/events")
          component.with_nav_item(text: "Vendors", url: "/vendors")
        end

        expect(page).to have_link("Dashboard", href: "/dashboard")
        expect(page).to have_link("Events", href: "/events")
        expect(page).to have_link("Vendors", href: "/vendors")
        expect(page).to have_css("a.px-3.py-2.rounded-md", count: 6) # 3 desktop + 3 mobile
      end

      it "marks active nav item" do
        render_inline(described_class.new) do |component|
          component.with_nav_item(text: "Dashboard", url: "/dashboard", active: true)
          component.with_nav_item(text: "Events", url: "/events", active: false)
        end

        expect(page).to have_css("a.bg-slate-100.text-slate-700", count: 2) # desktop + mobile
        expect(page).to have_css("a.text-slate-700.hover\\:bg-slate-100", count: 2) # desktop + mobile
      end

      it "adds aria-current to active nav items" do
        render_inline(described_class.new) do |component|
          component.with_nav_item(text: "Dashboard", url: "/dashboard", active: true)
          component.with_nav_item(text: "Events", url: "/events", active: false)
        end

        expect(page).to have_css("a[aria-current='page']", text: "Dashboard", count: 2) # desktop + mobile
        expect(page).not_to have_css("a[aria-current='page']", text: "Events")
      end

      it "renders nav items in mobile menu" do
        render_inline(described_class.new) do |component|
          component.with_nav_item(text: "Dashboard", url: "/dashboard")
        end

        mobile_menu = page.find("div[data-components--navbar-target='menu']")
        expect(mobile_menu).to have_link("Dashboard", href: "/dashboard")
      end
    end

    context "without nav_items slot" do
      it "renders empty navigation section" do
        render_inline(described_class.new)

        desktop_nav = page.all(".hidden.md\\:flex.md\\:items-center").first
        expect(desktop_nav).not_to have_css("a")
      end
    end

    context "with actions slot" do
      it "renders single action" do
        render_inline(described_class.new) do |component|
          component.with_action do
            "<button class='btn'>Sign out</button>".html_safe
          end
        end

        expect(page).to have_css("button.btn", text: "Sign out", count: 2) # desktop + mobile
      end

      it "renders multiple actions" do
        render_inline(described_class.new) do |component|
          component.with_action do
            "<button class='btn'>Profile</button>".html_safe
          end
          component.with_action do
            "<button class='btn'>Sign out</button>".html_safe
          end
        end

        expect(page).to have_css("button.btn", count: 4) # 2 desktop + 2 mobile
      end

      it "renders actions in mobile menu" do
        render_inline(described_class.new) do |component|
          component.with_action do
            "<button class='btn'>Sign out</button>".html_safe
          end
        end

        mobile_menu = page.find("div[data-components--navbar-target='menu']")
        expect(mobile_menu).to have_css("button.btn", text: "Sign out")
      end
    end

    context "without actions slot" do
      it "does not render actions section in mobile menu" do
        render_inline(described_class.new)

        mobile_menu = page.find("div[data-components--navbar-target='menu']")
        expect(mobile_menu).not_to have_css(".pt-4.pb-3.border-t")
      end
    end
  end

  describe "complete navbar example" do
    it "renders full navbar with all slots" do
      render_inline(described_class.new(variant: :default, sticky: true)) do |component|
        component.with_logo do
          "<a href='/' class='font-bold text-xl'>EventEssentials</a>".html_safe
        end

        component.with_nav_item(text: "Dashboard", url: "/dashboard", active: true)
        component.with_nav_item(text: "Events", url: "/events")
        component.with_nav_item(text: "Vendors", url: "/vendors")

        component.with_action do
          "<button class='btn btn-sm'>Sign out</button>".html_safe
        end
      end

      # Navbar structure
      expect(page).to have_css("nav.sticky.top-0.z-50")

      # Logo
      expect(page).to have_link("EventEssentials", href: "/")

      # Navigation items
      expect(page).to have_link("Dashboard", href: "/dashboard")
      expect(page).to have_link("Events", href: "/events")
      expect(page).to have_link("Vendors", href: "/vendors")

      # Active state
      expect(page).to have_css("a.bg-slate-100.text-slate-700", text: "Dashboard")
      expect(page).to have_css("a[aria-current='page']", text: "Dashboard")

      # Actions
      expect(page).to have_css("button.btn.btn-sm", text: "Sign out")

      # Mobile menu
      expect(page).to have_css("button[aria-controls='mobile-menu']")
      expect(page).to have_css("div#mobile-menu[data-components--navbar-target='menu']")
    end
  end

  describe "accessibility" do
    it "has proper ARIA attributes on mobile menu button" do
      render_inline(described_class.new)

      button = page.find("button[data-components--navbar-target='menuButton']")
      expect(button["aria-controls"]).to eq("mobile-menu")
      expect(button["aria-expanded"]).to eq("false")
    end

    it "has screen reader text for mobile menu button" do
      render_inline(described_class.new)

      # Should have screen reader text (locale-independent check)
      expect(page).to have_css(".sr-only")
      sr_text = page.find(".sr-only").text
      expect(sr_text).to match(/menu/i) # Should contain "menu" in any language
    end

    it "has proper ARIA hidden on icons" do
      render_inline(described_class.new)

      expect(page).to have_css("svg[aria-hidden='true']", count: 2)
    end

    it "has aria-hidden on mobile menu when closed" do
      render_inline(described_class.new)

      mobile_menu = page.find("div[data-components--navbar-target='menu']")
      expect(mobile_menu["aria-hidden"]).to eq("true")
    end
  end

  describe "responsive behavior" do
    it "hides desktop navigation on mobile" do
      render_inline(described_class.new)

      expect(page).to have_css(".hidden.md\\:flex.md\\:items-center")
    end

    it "hides mobile menu button on desktop" do
      render_inline(described_class.new)

      expect(page).to have_css(".flex.md\\:hidden")
    end

    it "hides mobile menu by default" do
      render_inline(described_class.new)

      expect(page).to have_css("div[data-components--navbar-target='menu'].hidden.md\\:hidden")
    end
  end

  describe "NavItemComponent" do
    let(:nav_item) { described_class::NavItemComponent.new(text: "Dashboard", url: "/dashboard") }

    it "renders as a link" do
      render_inline(nav_item)

      expect(page).to have_link("Dashboard", href: "/dashboard")
    end

    it "applies item classes" do
      render_inline(nav_item)

      expect(page).to have_css("a.px-3.py-2.rounded-md")
    end

    context "when active: true" do
      let(:active_nav_item) { described_class::NavItemComponent.new(text: "Dashboard", url: "/dashboard", active: true) }

      it "applies active classes" do
        render_inline(active_nav_item)

        expect(page).to have_css("a.bg-slate-100.text-slate-700")
      end

      it "adds aria-current='page' attribute" do
        render_inline(active_nav_item)

        expect(page).to have_css("a[aria-current='page']")
      end
    end

    context "when active: false" do
      it "applies inactive classes" do
        render_inline(nav_item)

        expect(page).to have_css("a.text-slate-700.hover\\:bg-slate-100")
      end

      it "does not add aria-current attribute" do
        render_inline(nav_item)

        expect(page).not_to have_css("a[aria-current]")
      end
    end

    context "with custom HTML attributes" do
      let(:custom_nav_item) { described_class::NavItemComponent.new(text: "Custom", url: "/custom", data: { turbo: false }) }

      it "merges custom attributes" do
        render_inline(custom_nav_item)

        expect(page).to have_link("Custom", href: "/custom")
        expect(page).to have_css("a[data-turbo='false']")
      end
    end
  end
end
