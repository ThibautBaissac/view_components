# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::BadgeComponent, type: :component do
  describe "rendering" do
    context "with basic configuration" do
      it "renders badge with text" do
        render_inline(described_class.new(text: "New"))

        expect(page).to have_css("span.badge", text: "New")
      end

      it "renders with default variant (subtle)" do
        render_inline(described_class.new(text: "Default"))

        expect(page).to have_css("span.badge")
        expect(page).to have_css("span", text: "Default")
      end

      it "renders with default color (neutral)" do
        render_inline(described_class.new(text: "Neutral"))

        expect(page).to have_css("span.bg-slate-100.text-slate-800")
      end

      it "renders with default size (small)" do
        render_inline(described_class.new(text: "Small"))

        expect(page).to have_css("span.px-2\\.5.py-0\\.5.text-xs")
      end

      it "includes base badge classes" do
        render_inline(described_class.new(text: "Badge"))

        expect(page).to have_css("span.inline-flex.items-center.gap-1\\.5.font-semibold")
      end
    end

    context "with different variants" do
      it "renders solid variant" do
        render_inline(described_class.new(text: "Solid", variant: :solid))

        expect(page).to have_css("span.bg-slate-600.text-white")
      end

      it "renders subtle variant" do
        render_inline(described_class.new(text: "Subtle", variant: :subtle))

        expect(page).to have_css("span.bg-slate-100.text-slate-800.border.border-slate-200")
      end

      it "renders outline variant" do
        render_inline(described_class.new(text: "Outline", variant: :outline))

        expect(page).to have_css("span.border-2.border-slate-300.text-slate-700.bg-white")
      end
    end

    context "with different colors" do
      it "renders neutral color" do
        render_inline(described_class.new(text: "Neutral", color: :neutral))

        expect(page).to have_css("span", text: "Neutral")
      end

      it "renders primary color with subtle variant" do
        render_inline(described_class.new(text: "Primary", color: :primary, variant: :subtle))

        expect(page).to have_css("span.bg-indigo-50.text-indigo-700.border.border-indigo-200")
      end

      it "renders success color with solid variant" do
        render_inline(described_class.new(text: "Success", color: :success, variant: :solid))

        expect(page).to have_css("span.bg-green-600.text-white")
      end

      it "renders warning color" do
        render_inline(described_class.new(text: "Warning", color: :warning))

        expect(page).to have_css("span.bg-yellow-50.text-yellow-800")
      end

      it "renders danger color" do
        render_inline(described_class.new(text: "Danger", color: :danger))

        expect(page).to have_css("span.bg-red-50.text-red-700")
      end

      it "renders info color" do
        render_inline(described_class.new(text: "Info", color: :info))

        expect(page).to have_css("span.bg-sky-50.text-sky-700")
      end

      it "renders secondary color" do
        render_inline(described_class.new(text: "Secondary", color: :secondary))

        expect(page).to have_css("span.bg-slate-50.text-slate-700")
      end
    end

    context "with different sizes" do
      it "renders small size" do
        render_inline(described_class.new(text: "Small", size: :small))

        expect(page).to have_css("span.px-2\\.5.py-0\\.5.text-xs")
      end

      it "renders medium size" do
        render_inline(described_class.new(text: "Medium", size: :medium))

        expect(page).to have_css("span.px-3.py-1.text-sm")
      end

      it "renders large size" do
        render_inline(described_class.new(text: "Large", size: :large))

        expect(page).to have_css("span.px-3\\.5.py-1\\.5.text-base")
      end
    end

    context "with pill shape" do
      it "renders with rounded corners by default" do
        render_inline(described_class.new(text: "Default"))

        expect(page).to have_css("span.rounded-md")
      end

      it "renders with pill shape when pill is true" do
        render_inline(described_class.new(text: "Pill", pill: true))

        expect(page).to have_css("span.rounded-full")
      end
    end

    context "with icon slot" do
      it "renders without icon by default" do
        render_inline(described_class.new(text: "No Icon"))

        expect(page).to have_css("span.badge", text: "No Icon")
      end

      it "renders with icon when provided" do
        component = described_class.new(text: "Status")

        render_inline(component) do |c|
          c.with_icon(name: "check-circle")
        end

        expect(page).to have_css("span.badge", text: "Status")
      end

      it "adapts icon variant to badge variant" do
        component = described_class.new(text: "Badge", variant: :outline)

        render_inline(component) do |c|
          c.with_icon(name: "check")
        end

        expect(page).to have_css("span.badge")
      end
    end

    context "with dismissible functionality" do
      it "does not render dismiss button by default" do
        render_inline(described_class.new(text: "Not Dismissible"))

        expect(page).not_to have_css('button[data-action*="dismiss"]')
      end

      it "renders dismiss button when dismissible is true" do
        render_inline(described_class.new(text: "Dismissible", dismissible: true))

        expect(page).to have_css('button[type="button"]')
        expect(page).to have_css('button[data-action="click->components--badge#dismiss"]')
        expect(page).to have_css('button[aria-label="Retirer le badge"]')
      end

      it "includes Stimulus controller when dismissible" do
        render_inline(described_class.new(text: "Tag", dismissible: true))

        expect(page).to have_css('[data-controller="components--badge"]')
      end

      it "does not include Stimulus controller when not dismissible" do
        render_inline(described_class.new(text: "Tag"))

        expect(page).not_to have_css('[data-controller="components--badge"]')
      end

      it "renders x-mark icon in dismiss button" do
        render_inline(described_class.new(text: "Tag", dismissible: true))

        expect(page).to have_css('button[aria-label="Retirer le badge"]')
      end
    end

    context "with block content" do
      it "renders block content when no text provided" do
        component = described_class.new

        render_inline(component) { "Custom Content" }

        expect(page).to have_css("span.badge", text: "Custom Content")
      end

      it "prefers text parameter over block content" do
        component = described_class.new(text: "Text Parameter")

        render_inline(component) { "Block Content" }

        expect(page).to have_css("span.badge", text: "Text Parameter")
        expect(page).not_to have_text("Block Content")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(text: "Custom", class: "custom-badge"))

        expect(page).to have_css("span.badge.custom-badge")
      end

      it "renders with custom ID" do
        render_inline(described_class.new(text: "Badge", id: "my-badge"))

        expect(page).to have_css("span#my-badge")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(text: "Badge", data: { testid: "badge-1" }))

        expect(page).to have_css('[data-testid="badge-1"]')
      end
    end
  end

  describe "#render?" do
    it "renders when text is present" do
      component = described_class.new(text: "Badge")

      expect(component.render?).to be true
    end

    it "renders when block content is provided" do
      component = described_class.new

      render_inline(component) { "Content" }

      # After rendering, component has content
      expect(page).to have_css("span.badge", text: "Content")
    end

    it "does not render when text is nil" do
      component = described_class.new(text: nil)

      # render? checks @text.present?, which is false for nil
      expect(component.render?).to be_falsey
    end

    it "does not render when text is empty string" do
      component = described_class.new(text: "")

      # render? checks @text.present?, which is false for empty string
      expect(component.render?).to be_falsey
    end

    it "actually skips rendering when conditions not met" do
      result = render_inline(described_class.new(text: nil))

      expect(result.to_html.strip).to be_empty
    end
  end

  describe "validation" do
    context "variant validation" do
      it "accepts valid solid variant" do
        expect {
          described_class.new(text: "Test", variant: :solid)
        }.not_to raise_error
      end

      it "accepts valid subtle variant" do
        expect {
          described_class.new(text: "Test", variant: :subtle)
        }.not_to raise_error
      end

      it "accepts valid outline variant" do
        expect {
          described_class.new(text: "Test", variant: :outline)
        }.not_to raise_error
      end

      it "raises error for invalid variant" do
        expect {
          described_class.new(text: "Test", variant: :invalid)
        }.to raise_error(ArgumentError, /Invalid variant: invalid. Must be one of solid, subtle, outline/)
      end
    end

    context "color validation" do
      Display::BadgeComponent::COLORS.each do |color|
        it "accepts valid #{color} color" do
          expect {
            described_class.new(text: "Test", color: color)
          }.not_to raise_error
        end
      end

      it "raises error for invalid color" do
        expect {
          described_class.new(text: "Test", color: :invalid)
        }.to raise_error(ArgumentError, /Invalid color: invalid/)
      end
    end

    context "size validation" do
      it "accepts valid small size" do
        expect {
          described_class.new(text: "Test", size: :small)
        }.not_to raise_error
      end

      it "accepts valid medium size" do
        expect {
          described_class.new(text: "Test", size: :medium)
        }.not_to raise_error
      end

      it "accepts valid large size" do
        expect {
          described_class.new(text: "Test", size: :large)
        }.not_to raise_error
      end

      it "raises error for invalid size" do
        expect {
          described_class.new(text: "Test", size: :invalid)
        }.to raise_error(ArgumentError, /Invalid size: invalid/)
      end
    end
  end

  describe "accessibility" do
    it "uses semantic span element" do
      render_inline(described_class.new(text: "Badge"))

      expect(page).to have_css("span.badge")
    end

    it "includes French aria-label on dismiss button" do
      render_inline(described_class.new(text: "Tag", dismissible: true))

      expect(page).to have_css('button[aria-label="Retirer le badge"]')
    end

    it "allows custom dismiss label override" do
      render_inline(described_class.new(text: "Tag", dismissible: true, dismiss_label: "Supprimer"))

      expect(page).to have_css('button[aria-label="Supprimer"]')
    end

    it "dismiss button has proper type attribute" do
      render_inline(described_class.new(text: "Tag", dismissible: true))

      expect(page).to have_css('button[type="button"]')
    end

    it "supports ARIA role for status badges" do
      render_inline(described_class.new(text: "Active", role: "status"))

      expect(page).to have_css('span[role="status"]')
    end

    it "does not add role attribute when not specified" do
      render_inline(described_class.new(text: "Badge"))

      expect(page).not_to have_css('span[role]')
    end
  end

  describe "edge cases" do
    it "handles special characters in text" do
      render_inline(described_class.new(text: "Test <script>alert('xss')</script>"))

      expect(page).to have_css("span.badge")
      expect(page).not_to have_css("script")
    end

    it "handles long text" do
      long_text = "a" * 100
      render_inline(described_class.new(text: long_text))

      expect(page).to have_css("span.badge", text: long_text)
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        text: "Complete",
        variant: :solid,
        color: :success,
        size: :large,
        pill: true,
        dismissible: true,
        class: "custom-badge",
        id: "badge-1"
      ))

      expect(page).to have_css("span#badge-1.badge.custom-badge")
      expect(page).to have_css("span.bg-green-600.text-white")
      expect(page).to have_css("span.px-3\\.5.py-1\\.5.text-base")
      expect(page).to have_css("span.rounded-full")
      expect(page).to have_css('button[data-action="click->components--badge#dismiss"]')
    end

    it "handles string variant/color/size (symbol conversion)" do
      render_inline(described_class.new(
        text: "Test",
        variant: "solid",
        color: "primary",
        size: "medium"
      ))

      expect(page).to have_css("span.badge")
      expect(page).to have_css("span.bg-indigo-600")
    end
  end

  describe "icon size mapping" do
    it "uses xs icon for small badge" do
      component = described_class.new(text: "Badge", size: :small)

      render_inline(component) do |c|
        c.with_icon(name: "check")
      end

      expect(page).to have_css("span.badge")
    end

    it "uses small icon for medium badge" do
      component = described_class.new(text: "Badge", size: :medium)

      render_inline(component) do |c|
        c.with_icon(name: "check")
      end

      expect(page).to have_css("span.badge")
    end

    it "uses medium icon for large badge" do
      component = described_class.new(text: "Badge", size: :large)

      render_inline(component) do |c|
        c.with_icon(name: "check")
      end

      expect(page).to have_css("span.badge")
    end
  end
end
