# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::LinkComponent, type: :component do
  describe "initialization" do
    it "requires href parameter" do
      component = described_class.new(href: "/users", text: "Users")

      expect(component.instance_variable_get(:@href)).to eq("/users")
    end

    it "initializes with target" do
      component = described_class.new(href: "/users", target: "_blank")

      expect(component.instance_variable_get(:@target)).to eq("_blank")
    end

    it "initializes with rel" do
      component = described_class.new(href: "/users", rel: "nofollow")

      expect(component.instance_variable_get(:@rel)).to eq("nofollow")
    end

    it "inherits from BaseButtonComponent" do
      expect(described_class.superclass).to eq(Foundation::BaseButtonComponent)
    end

    it "initializes with variant" do
      component = described_class.new(href: "/users", variant: :primary)

      expect(component.instance_variable_get(:@variant)).to eq(:primary)
    end

    it "initializes with size" do
      component = described_class.new(href: "/users", size: :large)

      expect(component.instance_variable_get(:@size)).to eq(:large)
    end

    it "initializes with disabled" do
      component = described_class.new(href: "/users", disabled: true)

      expect(component.instance_variable_get(:@disabled)).to be true
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders link element" do
        render_inline(described_class.new(href: "/users", text: "Users"))

        expect(page).to have_link("Users", href: "/users")
      end

      it "renders link without text" do
        render_inline(described_class.new(href: "/users"))

        expect(page).to have_css('a[href="/users"]')
      end

      it "renders with absolute URL" do
        render_inline(described_class.new(href: "https://example.com", text: "Example"))

        expect(page).to have_link("Example", href: "https://example.com")
      end
    end

    context "with target attribute" do
      it "renders with target blank" do
        render_inline(described_class.new(href: "https://example.com", text: "Example", target: "_blank"))

        expect(page).to have_css('a[target="_blank"]')
      end

      it "renders with target self" do
        render_inline(described_class.new(href: "/users", text: "Users", target: "_self"))

        expect(page).to have_css('a[target="_self"]')
      end

      it "does not render target when not provided" do
        render_inline(described_class.new(href: "/users", text: "Users"))

        expect(page).not_to have_css("a[target]")
      end
    end

    context "with rel attribute" do
      it "auto-adds noopener noreferrer for target blank" do
        render_inline(described_class.new(href: "https://example.com", text: "Example", target: "_blank"))

        expect(page).to have_css('a[rel="noopener noreferrer"]')
      end

      it "combines custom rel with auto-added security attributes" do
        render_inline(described_class.new(href: "https://example.com", text: "Example", target: "_blank", rel: "nofollow"))

        expect(page).to have_css('a[rel]')
        # Should contain all three: nofollow, noopener, noreferrer
        link = page.find("a")
        rel_values = link[:rel].split
        expect(rel_values).to include("nofollow")
        expect(rel_values).to include("noopener")
        expect(rel_values).to include("noreferrer")
      end

      it "renders custom rel without target blank" do
        render_inline(described_class.new(href: "/users", text: "Users", rel: "nofollow"))

        expect(page).to have_css('a[rel="nofollow"]')
      end

      it "does not render rel when not provided and no target blank" do
        render_inline(described_class.new(href: "/users", text: "Users"))

        expect(page).not_to have_css("a[rel]")
      end
    end

    context "with disabled state" do
      it "renders aria-disabled when disabled" do
        render_inline(described_class.new(href: "/users", text: "Users", disabled: true))

        expect(page).to have_css('a[aria-disabled="true"]')
      end

      it "renders tabindex -1 when disabled" do
        render_inline(described_class.new(href: "/users", text: "Users", disabled: true))

        expect(page).to have_css('a[tabindex="-1"]')
      end

      it "applies disabled styles when disabled" do
        render_inline(described_class.new(href: "/users", text: "Users", disabled: true))

        expect(page).to have_css("a.opacity-60.cursor-not-allowed")
      end

      it "does not render aria-disabled when not disabled" do
        render_inline(described_class.new(href: "/users", text: "Users", disabled: false))

        expect(page).not_to have_css("a[aria-disabled]")
      end

      it "does not render tabindex when not disabled" do
        render_inline(described_class.new(href: "/users", text: "Users", disabled: false))

        expect(page).not_to have_css('a[tabindex="-1"]')
      end
    end

    context "with variant styles" do
      it "renders primary variant" do
        render_inline(described_class.new(href: "/users", text: "Users", variant: :primary))

        expect(page).to have_css("a.bg-indigo-600.text-white")
      end

      it "renders secondary variant" do
        render_inline(described_class.new(href: "/users", text: "Users", variant: :secondary))

        expect(page).to have_css("a.bg-slate-600.text-white")
      end

      it "renders success variant" do
        render_inline(described_class.new(href: "/users", text: "Save", variant: :success))

        expect(page).to have_css("a.bg-green-600.text-white")
      end

      it "renders danger variant" do
        render_inline(described_class.new(href: "/users", text: "Delete", variant: :danger))

        expect(page).to have_css("a.bg-red-600.text-white")
      end

      it "renders outline variant" do
        render_inline(described_class.new(href: "/users", text: "Users", variant: :outline))

        expect(page).to have_css("a.border-2.border-indigo-600.text-indigo-700")
      end

      it "renders ghost variant" do
        render_inline(described_class.new(href: "/users", text: "Users", variant: :ghost))

        expect(page).to have_css("a.text-slate-700.hover\\:bg-slate-100\\/80")
      end

      it "renders link variant" do
        render_inline(described_class.new(href: "/users", text: "Users", variant: :link))

        expect(page).to have_css("a.text-indigo-600.hover\\:underline")
      end
    end

    context "with size styles" do
      it "renders small size" do
        render_inline(described_class.new(href: "/users", text: "Users", size: :small))

        expect(page).to have_css("a.px-3.py-2.text-sm")
      end

      it "renders medium size" do
        render_inline(described_class.new(href: "/users", text: "Users", size: :medium))

        expect(page).to have_css("a.px-5.py-2\\.5.text-base")
      end

      it "renders large size" do
        render_inline(described_class.new(href: "/users", text: "Users", size: :large))

        expect(page).to have_css("a.px-6.py-3.text-lg")
      end
    end

    context "with full_width" do
      it "renders full width link" do
        render_inline(described_class.new(href: "/users", text: "Users", full_width: true))

        expect(page).to have_css("a.w-full")
      end

      it "renders normal width link" do
        render_inline(described_class.new(href: "/users", text: "Users", full_width: false))

        expect(page).not_to have_css("a.w-full")
      end
    end

    context "with base classes" do
      it "includes base button classes" do
        render_inline(described_class.new(href: "/users", text: "Users"))

        expect(page).to have_css("a.inline-flex.items-center.justify-center.gap-2")
        expect(page).to have_css("a.font-semibold.transition-all.duration-200")
      end

      it "includes focus ring classes" do
        render_inline(described_class.new(href: "/users", text: "Users"))

        expect(page).to have_css("a.focus\\:outline-none.focus\\:ring-2")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(href: "/users", text: "Users", class: "custom-link"))

        expect(page).to have_css("a.custom-link")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(href: "/users", text: "Users", data: { turbo: false }))

        expect(page).to have_css('a[data-turbo="false"]')
      end

      it "renders with custom ID" do
        render_inline(described_class.new(href: "/users", text: "Users", id: "users-link"))

        expect(page).to have_css("a#users-link")
      end
    end
  end

  describe "accessibility" do
    context "with text" do
      it "does not raise accessibility warning with text" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(href: "/users", text: "Users")
      end
    end

    context "without text (icon-only)" do
      it "warns in development when no accessible name provided" do
        allow(Rails.env).to receive(:development?).and_return(true)
        expect(Rails.logger).to receive(:warn).with(/Missing accessible name/)

        described_class.new(href: "/users")
      end

      it "does not warn when aria-label provided" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(href: "/users", aria: { label: "View users" })
      end

      it "does not warn when title provided" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(href: "/users", title: "View users")
      end
    end

    it "includes proper focus styles for keyboard navigation" do
      render_inline(described_class.new(href: "/users", text: "Users"))

      expect(page).to have_css("a.focus\\:ring-2")
    end

    it "properly marks disabled links" do
      render_inline(described_class.new(href: "/users", text: "Users", disabled: true))

      expect(page).to have_css('a[aria-disabled="true"]')
      expect(page).to have_css('a[tabindex="-1"]')
    end
  end

  describe "edge cases" do
    it "combines multiple configuration options" do
      render_inline(described_class.new(
        href: "https://example.com/users",
        text: "View Users",
        variant: :primary,
        size: :large,
        target: "_blank",
        rel: "nofollow",
        disabled: false,
        full_width: true,
        class: "users-link",
        id: "view-users",
        data: { controller: "analytics" }
      ))

      expect(page).to have_link("View Users", href: "https://example.com/users")
      expect(page).to have_css("a#view-users.users-link")
      expect(page).to have_css("a.bg-indigo-600.px-6.py-3.text-lg")
      expect(page).to have_css("a.w-full")
      expect(page).to have_css('a[target="_blank"]')
      expect(page).to have_css('a[data-controller="analytics"]')

      # Check rel includes all values
      link = page.find("a")
      rel_values = link[:rel].split
      expect(rel_values).to include("nofollow")
      expect(rel_values).to include("noopener")
      expect(rel_values).to include("noreferrer")
    end

    it "handles special characters in href" do
      render_inline(described_class.new(href: "/search?q=test&page=1", text: "Search"))

      expect(page).to have_link("Search", href: "/search?q=test&page=1")
    end

    it "handles special characters in text" do
      render_inline(described_class.new(href: "/users", text: "Users & Groups"))

      expect(page).to have_link("Users & Groups")
    end

    it "handles anchor links" do
      render_inline(described_class.new(href: "#section", text: "Jump to section"))

      expect(page).to have_link("Jump to section", href: "#section")
    end

    it "handles mailto links" do
      render_inline(described_class.new(href: "mailto:test@example.com", text: "Email us"))

      expect(page).to have_link("Email us", href: "mailto:test@example.com")
    end

    it "handles tel links" do
      render_inline(described_class.new(href: "tel:+1234567890", text: "Call us"))

      expect(page).to have_link("Call us", href: "tel:+1234567890")
    end

    it "renders all variant combinations" do
      Foundation::BaseButtonComponent::VARIANTS.each do |variant|
        render_inline(described_class.new(href: "/users", text: "Link", variant: variant))

        expect(page).to have_link("Link", href: "/users")
      end
    end

    it "handles disabled link with target blank" do
      render_inline(described_class.new(
        href: "https://example.com",
        text: "Example",
        target: "_blank",
        disabled: true
      ))

      expect(page).to have_css('a[aria-disabled="true"]')
      expect(page).to have_css('a[tabindex="-1"]')
      expect(page).to have_css('a[target="_blank"]')
      expect(page).to have_css('a[rel="noopener noreferrer"]')
    end

    it "handles empty rel attribute" do
      render_inline(described_class.new(href: "/users", text: "Users", rel: ""))

      expect(page).not_to have_css("a[rel]")
    end

    it "deduplicates rel values" do
      render_inline(described_class.new(
        href: "https://example.com",
        text: "Example",
        target: "_blank",
        rel: "noopener nofollow"
      ))

      expect(page).to have_css("a[rel]")
      link = page.find("a")
      rel_values = link[:rel].split

      # Should include all expected values
      expect(rel_values).to include("noopener")
      expect(rel_values).to include("noreferrer")
      expect(rel_values).to include("nofollow")
    end
  end
end
