# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::SpinnerComponent, type: :component do
  describe "rendering" do
    it "renders a basic spinner" do
      render_inline(described_class.new)

      expect(page).to have_css('[role="status"]')
      expect(page).to have_css('.animate-spin')
      expect(page).to have_css('.sr-only', text: "Chargement en cours...")
    end

    it "renders with custom aria-label" do
      render_inline(described_class.new(aria_label: "Chargement des données..."))

      expect(page).to have_css('[role="status"]')
      expect(page).to have_css('.sr-only', text: "Chargement des données...")
    end

    it "renders with visible label" do
      render_inline(described_class.new(label: "Chargement..."))

      expect(page).to have_text("Chargement...")
      expect(page).to have_css('span', text: "Chargement...")
    end

    it "renders centered layout" do
      render_inline(described_class.new(centered: true))

      expect(page).to have_css('.flex.flex-col.items-center.justify-center')
    end

    it "renders inline layout" do
      render_inline(described_class.new(inline: true))

      expect(page).to have_css('.inline-flex.items-center')
    end

    context "with different sizes" do
      it "renders xs size" do
        render_inline(described_class.new(size: :xs))

        expect(page).to have_css('.w-3.h-3')
      end

      it "renders small size" do
        render_inline(described_class.new(size: :small))

        expect(page).to have_css('.w-4.h-4')
      end

      it "renders medium size (default)" do
        render_inline(described_class.new)

        expect(page).to have_css('.w-6.h-6')
      end

      it "renders large size" do
        render_inline(described_class.new(size: :large))

        expect(page).to have_css('.w-8.h-8')
      end

      it "renders xl size" do
        render_inline(described_class.new(size: :xl))

        expect(page).to have_css('.w-12.h-12')
      end
    end

    context "with different colors" do
      it "renders primary color (default)" do
        render_inline(described_class.new)

        expect(page).to have_css('.border-indigo-600')
      end

      it "renders secondary color" do
        render_inline(described_class.new(color: :secondary))

        expect(page).to have_css('.border-slate-600')
      end

      it "renders success color" do
        render_inline(described_class.new(color: :success))

        expect(page).to have_css('.border-green-600')
      end

      it "renders danger color" do
        render_inline(described_class.new(color: :danger))

        expect(page).to have_css('.border-red-600')
      end

      it "renders white color" do
        render_inline(described_class.new(color: :white))

        expect(page).to have_css('.border-white')
      end

      it "renders warning color" do
        render_inline(described_class.new(color: :warning))

        expect(page).to have_css('.border-yellow-500')
      end

      it "renders info color" do
        render_inline(described_class.new(color: :info))

        expect(page).to have_css('.border-sky-500')
      end
    end
  end

  describe "HTML attributes" do
    it "merges custom HTML attributes" do
      render_inline(described_class.new(id: "custom-spinner", data: { testid: "loading" }))

      expect(page).to have_css('[id="custom-spinner"]')
      expect(page).to have_css('[data-testid="loading"]')
    end

    it "applies custom classes alongside default classes" do
      render_inline(described_class.new(class: "custom-class another-class"))

      # Check that the container has both default and custom classes
      container = page.find('[role="status"]')
      expect(container[:class]).to include('flex', 'items-center', 'gap-2')
      expect(container[:class]).to include('custom-class', 'another-class')
    end

    it "merges custom ARIA attributes" do
      render_inline(described_class.new(aria: { live: "polite", atomic: "true" }))

      expect(page).to have_css('[aria-live="polite"]')
      expect(page).to have_css('[aria-atomic="true"]')
    end

    it "applies custom data attributes" do
      render_inline(described_class.new(data: { controller: "spinner", action: "click->spinner#toggle" }))

      expect(page).to have_css('[data-controller="spinner"]')
      expect(page).to have_css('[data-action="click->spinner#toggle"]')
    end
  end

  describe "validation" do
    it "raises error for invalid size" do
      expect {
        described_class.new(size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size/)
    end

    it "raises error for invalid color" do
      expect {
        described_class.new(color: :invalid)
      }.to raise_error(ArgumentError, /Invalid color/)
    end
  end

  describe "accessibility" do
    it "has proper ARIA attributes" do
      render_inline(described_class.new)

      expect(page).to have_css('[role="status"]')
      expect(page).to have_css('.sr-only')
    end

    it "hides spinner from screen readers" do
      render_inline(described_class.new)

      expect(page).to have_css('[aria-hidden="true"]')
    end

    it "announces loading status only once via sr-only span" do
      render_inline(described_class.new(aria_label: "Chargement des données..."))

      # Should have exactly one sr-only element with the aria label
      expect(page).to have_css('.sr-only', text: "Chargement des données...", count: 1)

      # Container should NOT have aria-label attribute (to avoid double announcement)
      expect(page).not_to have_css('[role="status"][aria-label]')
    end
  end
end
