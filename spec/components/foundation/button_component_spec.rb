# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::ButtonComponent, type: :component do
  describe "initialization" do
    it "initializes with default type" do
      component = described_class.new(text: "Button")

      expect(component.instance_variable_get(:@type)).to eq(:button)
    end

    it "initializes with custom type" do
      component = described_class.new(text: "Button", type: :submit)

      expect(component.instance_variable_get(:@type)).to eq(:submit)
    end

    it "initializes with loading false by default" do
      component = described_class.new(text: "Button")

      expect(component.instance_variable_get(:@loading)).to be false
    end

    it "initializes with loading true when provided" do
      component = described_class.new(text: "Button", loading: true)

      expect(component.instance_variable_get(:@loading)).to be true
    end

    it "inherits from BaseButtonComponent" do
      expect(described_class.superclass).to eq(Foundation::BaseButtonComponent)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders button element" do
        render_inline(described_class.new(text: "Click me"))

        expect(page).to have_button("Click me")
      end

      it "renders with default type attribute" do
        render_inline(described_class.new(text: "Button"))

        expect(page).to have_css('button[type="button"]')
      end

      it "renders with submit type" do
        render_inline(described_class.new(text: "Submit", type: :submit))

        expect(page).to have_css('button[type="submit"]')
      end

      it "renders with reset type" do
        render_inline(described_class.new(text: "Reset", type: :reset))

        expect(page).to have_css('button[type="reset"]')
      end
    end

    context "with disabled state" do
      it "renders disabled attribute when disabled" do
        render_inline(described_class.new(text: "Button", disabled: true))

        expect(page).to have_css("button[disabled]")
      end

      it "does not render disabled attribute when not disabled" do
        render_inline(described_class.new(text: "Button", disabled: false))

        expect(page).not_to have_css("button[disabled]")
      end

      it "includes aria-disabled when disabled" do
        render_inline(described_class.new(text: "Button", disabled: true))

        expect(page).to have_css('button[aria-disabled="true"]')
      end

      it "does not include aria-disabled when not disabled" do
        render_inline(described_class.new(text: "Button", disabled: false))

        expect(page).not_to have_css('button[aria-disabled]')
      end
    end

    context "with loading state" do
      it "renders disabled attribute when loading" do
        render_inline(described_class.new(text: "Button", loading: true))

        expect(page).to have_css("button[disabled]")
      end

      it "includes aria-busy when loading" do
        render_inline(described_class.new(text: "Button", loading: true))

        expect(page).to have_css('button[aria-busy="true"]')
      end

      it "does not include aria-busy when not loading" do
        render_inline(described_class.new(text: "Button", loading: false))

        expect(page).not_to have_css('button[aria-busy]')
      end

      it "includes aria-disabled when loading" do
        render_inline(described_class.new(text: "Button", loading: true))

        expect(page).to have_css('button[aria-disabled="true"]')
      end

      it "applies disabled styles when loading" do
        render_inline(described_class.new(text: "Button", loading: true))

        expect(page).to have_css("button.opacity-60.cursor-not-allowed")
      end
    end

    context "with variant styles" do
      it "renders primary variant" do
        render_inline(described_class.new(text: "Button", variant: :primary))

        expect(page).to have_css("button.bg-indigo-600.text-white")
      end

      it "renders danger variant" do
        render_inline(described_class.new(text: "Delete", variant: :danger))

        expect(page).to have_css("button.bg-red-600.text-white")
      end
    end

    context "with size styles" do
      it "renders small size" do
        render_inline(described_class.new(text: "Button", size: :small))

        expect(page).to have_css("button.px-3.py-2.text-sm")
      end

      it "renders large size" do
        render_inline(described_class.new(text: "Button", size: :large))

        expect(page).to have_css("button.px-6.py-3.text-lg")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(text: "Button", class: "custom-btn"))

        expect(page).to have_css("button.custom-btn")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(text: "Button", data: { controller: "form" }))

        expect(page).to have_css('button[data-controller="form"]')
      end

      it "renders with custom ID" do
        render_inline(described_class.new(text: "Button", id: "submit-btn"))

        expect(page).to have_css("button#submit-btn")
      end
    end
  end

  describe "#disabled?" do
    it "returns true when disabled is true" do
      component = described_class.new(text: "Button", disabled: true)

      expect(component.send(:disabled?)).to be true
    end

    it "returns true when loading is true" do
      component = described_class.new(text: "Button", loading: true)

      expect(component.send(:disabled?)).to be true
    end

    it "returns true when both disabled and loading are true" do
      component = described_class.new(text: "Button", disabled: true, loading: true)

      expect(component.send(:disabled?)).to be true
    end

    it "returns false when both disabled and loading are false" do
      component = described_class.new(text: "Button", disabled: false, loading: false)

      expect(component.send(:disabled?)).to be false
    end
  end

  describe "#loading?" do
    it "returns true when loading is true" do
      component = described_class.new(text: "Button", loading: true)

      expect(component.send(:loading?)).to be true
    end

    it "returns false when loading is false" do
      component = described_class.new(text: "Button", loading: false)

      expect(component.send(:loading?)).to be false
    end
  end

  describe "accessibility" do
    context "with text" do
      it "does not raise accessibility warning with text" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(text: "Click me")
      end
    end

    context "without text (icon-only)" do
      it "warns in development when no accessible name provided" do
        allow(Rails.env).to receive(:development?).and_return(true)
        expect(Rails.logger).to receive(:warn).with(/Missing accessible name/)

        described_class.new
      end

      it "does not warn when aria-label provided" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(aria: { label: "Close" })
      end

      it "does not warn when title provided" do
        expect(Rails.logger).not_to receive(:warn)

        described_class.new(title: "Close")
      end
    end

    it "includes focus ring classes" do
      render_inline(described_class.new(text: "Button"))

      expect(page).to have_css("button.focus\\:outline-none.focus\\:ring-2")
    end
  end

  describe "edge cases" do
    it "combines multiple configuration options" do
      render_inline(described_class.new(
        text: "Save Changes",
        variant: :primary,
        size: :large,
        type: :submit,
        disabled: false,
        loading: false,
        full_width: true,
        class: "save-btn",
        data: { action: "click->form#save" }
      ))

      expect(page).to have_button("Save Changes")
      expect(page).to have_css('button[type="submit"]')
      expect(page).to have_css("button.bg-indigo-600.px-6.py-3")
      expect(page).to have_css("button.w-full.save-btn")
      expect(page).to have_css('button[data-action="click->form#save"]')
      expect(page).not_to have_css("button[disabled]")
    end

    it "handles loading and disabled together" do
      render_inline(described_class.new(
        text: "Processing",
        disabled: true,
        loading: true
      ))

      expect(page).to have_css("button[disabled]")
      expect(page).to have_css('button[aria-disabled="true"]')
      expect(page).to have_css('button[aria-busy="true"]')
    end

    it "handles all button types" do
      %i[button submit reset].each do |type|
        render_inline(described_class.new(text: "Button", type: type))

        expect(page).to have_css("button[type=\"#{type}\"]")
      end
    end

    it "renders all variant combinations with loading state" do
      Foundation::BaseButtonComponent::VARIANTS.each do |variant|
        render_inline(described_class.new(
          text: "Button",
          variant: variant,
          loading: true
        ))

        expect(page).to have_css("button[disabled]")
        expect(page).to have_css('button[aria-busy="true"]')
      end
    end

    it "handles special characters in text" do
      render_inline(described_class.new(text: "Save & Exit"))

      expect(page).to have_button("Save & Exit")
    end

    it "renders without text" do
      render_inline(described_class.new(variant: :ghost))

      expect(page).to have_button
    end
  end
end
