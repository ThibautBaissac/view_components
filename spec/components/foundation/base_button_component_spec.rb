# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::BaseButtonComponent, type: :component do
  # Create a concrete test component since BaseButtonComponent is abstract
  before do
    stub_const("TestBaseButtonComponent", Class.new(described_class) do
      def initialize(text: nil, variant: :primary, size: :medium, disabled: false, full_width: false, **html_attributes)
        super
      end

      def call
        tag.button(class: element_classes, **merged_html_attributes) do
          concat(icon_leading) if icon_leading?
          concat(@text) if @text.present?
          concat(icon_trailing) if icon_trailing?
        end
      end
    end)
  end

  let(:test_component_class) { TestBaseButtonComponent }

  describe "initialization" do
    it "initializes with text" do
      component = test_component_class.new(text: "Click me")

      expect(component.instance_variable_get(:@text)).to eq("Click me")
    end

    it "initializes with default variant" do
      component = test_component_class.new(text: "Button")

      expect(component.instance_variable_get(:@variant)).to eq(:primary)
    end

    it "initializes with custom variant" do
      component = test_component_class.new(text: "Button", variant: :secondary)

      expect(component.instance_variable_get(:@variant)).to eq(:secondary)
    end

    it "initializes with default size" do
      component = test_component_class.new(text: "Button")

      expect(component.instance_variable_get(:@size)).to eq(:medium)
    end

    it "initializes with custom size" do
      component = test_component_class.new(text: "Button", size: :large)

      expect(component.instance_variable_get(:@size)).to eq(:large)
    end

    it "initializes with disabled false by default" do
      component = test_component_class.new(text: "Button")

      expect(component.instance_variable_get(:@disabled)).to be false
    end

    it "initializes with disabled true when provided" do
      component = test_component_class.new(text: "Button", disabled: true)

      expect(component.instance_variable_get(:@disabled)).to be true
    end

    it "initializes with full_width false by default" do
      component = test_component_class.new(text: "Button")

      expect(component.instance_variable_get(:@full_width)).to be false
    end

    it "initializes with full_width true when provided" do
      component = test_component_class.new(text: "Button", full_width: true)

      expect(component.instance_variable_get(:@full_width)).to be true
    end

    it "accepts html_attributes" do
      component = test_component_class.new(text: "Button", class: "custom-class", data: { testid: "btn" })

      expect(component.instance_variable_get(:@html_attributes)).to include(class: "custom-class", data: { testid: "btn" })
    end
  end

  describe "variant validation" do
    it "accepts valid primary variant" do
      expect {
        test_component_class.new(text: "Button", variant: :primary)
      }.not_to raise_error
    end

    it "accepts valid secondary variant" do
      expect {
        test_component_class.new(text: "Button", variant: :secondary)
      }.not_to raise_error
    end

    it "accepts valid success variant" do
      expect {
        test_component_class.new(text: "Button", variant: :success)
      }.not_to raise_error
    end

    it "accepts valid danger variant" do
      expect {
        test_component_class.new(text: "Button", variant: :danger)
      }.not_to raise_error
    end

    it "accepts valid warning variant" do
      expect {
        test_component_class.new(text: "Button", variant: :warning)
      }.not_to raise_error
    end

    it "accepts valid outline variant" do
      expect {
        test_component_class.new(text: "Button", variant: :outline)
      }.not_to raise_error
    end

    it "accepts valid ghost variant" do
      expect {
        test_component_class.new(text: "Button", variant: :ghost)
      }.not_to raise_error
    end

    it "accepts valid link variant" do
      expect {
        test_component_class.new(text: "Button", variant: :link)
      }.not_to raise_error
    end

    it "raises error for invalid variant" do
      expect {
        test_component_class.new(text: "Button", variant: :invalid)
      }.to raise_error(ArgumentError, /Invalid variant: invalid. Valid variants are: primary, secondary, success, danger, warning, outline, ghost, link/)
    end
  end

  describe "size validation" do
    it "accepts valid small size" do
      expect {
        test_component_class.new(text: "Button", size: :small)
      }.not_to raise_error
    end

    it "accepts valid medium size" do
      expect {
        test_component_class.new(text: "Button", size: :medium)
      }.not_to raise_error
    end

    it "accepts valid large size" do
      expect {
        test_component_class.new(text: "Button", size: :large)
      }.not_to raise_error
    end

    it "raises error for invalid size" do
      expect {
        test_component_class.new(text: "Button", size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size: invalid. Valid sizes are: small, medium, large/)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders button with text" do
        render_inline(test_component_class.new(text: "Click me"))

        expect(page).to have_button("Click me")
      end

      it "renders button without text" do
        render_inline(test_component_class.new)

        expect(page).to have_button
      end
    end

    context "with variant styles" do
      it "renders primary variant" do
        render_inline(test_component_class.new(text: "Button", variant: :primary))

        expect(page).to have_css("button.bg-indigo-600.text-white")
        expect(page).to have_css("button.hover\\:bg-indigo-700")
        expect(page).to have_css("button.focus\\:ring-indigo-500")
      end

      it "renders secondary variant" do
        render_inline(test_component_class.new(text: "Button", variant: :secondary))

        expect(page).to have_css("button.bg-slate-600.text-white")
        expect(page).to have_css("button.hover\\:bg-slate-700")
        expect(page).to have_css("button.focus\\:ring-slate-500")
      end

      it "renders success variant" do
        render_inline(test_component_class.new(text: "Button", variant: :success))

        expect(page).to have_css("button.bg-green-600.text-white")
        expect(page).to have_css("button.hover\\:bg-green-700")
        expect(page).to have_css("button.focus\\:ring-green-500")
      end

      it "renders danger variant" do
        render_inline(test_component_class.new(text: "Button", variant: :danger))

        expect(page).to have_css("button.bg-red-600.text-white")
        expect(page).to have_css("button.hover\\:bg-red-700")
        expect(page).to have_css("button.focus\\:ring-red-500")
      end

      it "renders warning variant" do
        render_inline(test_component_class.new(text: "Button", variant: :warning))

        expect(page).to have_css("button.bg-yellow-700.text-white")
        expect(page).to have_css("button.hover\\:bg-yellow-800")
        expect(page).to have_css("button.focus\\:ring-yellow-700")
      end

      it "renders outline variant" do
        render_inline(test_component_class.new(text: "Button", variant: :outline))

        expect(page).to have_css("button.border-2.border-indigo-600")
        expect(page).to have_css("button.text-indigo-700")
        expect(page).to have_css("button.hover\\:bg-indigo-50")
      end

      it "renders ghost variant" do
        render_inline(test_component_class.new(text: "Button", variant: :ghost))

        expect(page).to have_css("button.text-slate-700")
        expect(page).to have_css("button.hover\\:bg-slate-100\\/80")
      end

      it "renders link variant" do
        render_inline(test_component_class.new(text: "Button", variant: :link))

        expect(page).to have_css("button.text-indigo-600")
        expect(page).to have_css("button.hover\\:underline")
      end
    end

    context "with size styles" do
      it "renders small size" do
        render_inline(test_component_class.new(text: "Button", size: :small))

        expect(page).to have_css("button.px-3.py-2.text-sm.rounded-lg")
      end

      it "renders medium size" do
        render_inline(test_component_class.new(text: "Button", size: :medium))

        expect(page).to have_css("button.px-5.py-2\\.5.text-base.rounded-lg")
      end

      it "renders large size" do
        render_inline(test_component_class.new(text: "Button", size: :large))

        expect(page).to have_css("button.px-6.py-3.text-lg.rounded-xl")
      end
    end

    context "with disabled state" do
      it "renders disabled button with opacity and cursor styles" do
        render_inline(test_component_class.new(text: "Button", disabled: true))

        expect(page).to have_css("button.opacity-60.cursor-not-allowed.saturate-50")
      end

      it "renders enabled button without disabled styles" do
        render_inline(test_component_class.new(text: "Button", disabled: false))

        expect(page).not_to have_css("button.opacity-60")
        expect(page).not_to have_css("button.cursor-not-allowed")
      end
    end

    context "with full_width" do
      it "renders full width button" do
        render_inline(test_component_class.new(text: "Button", full_width: true))

        expect(page).to have_css("button.w-full")
      end

      it "renders normal width button" do
        render_inline(test_component_class.new(text: "Button", full_width: false))

        expect(page).not_to have_css("button.w-full")
      end
    end

    context "with base classes" do
      it "includes base button classes" do
        render_inline(test_component_class.new(text: "Button"))

        expect(page).to have_css("button.inline-flex.items-center.justify-center.gap-2")
        expect(page).to have_css("button.font-semibold.transition-all.duration-200")
      end

      it "includes focus ring classes" do
        render_inline(test_component_class.new(text: "Button"))

        expect(page).to have_css("button.focus\\:outline-none.focus\\:ring-2.focus\\:ring-offset-2")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(test_component_class.new(text: "Button", class: "custom-class"))

        expect(page).to have_css("button.custom-class")
      end

      it "renders with custom data attributes" do
        render_inline(test_component_class.new(text: "Button", data: { testid: "my-button" }))

        expect(page).to have_css('button[data-testid="my-button"]')
      end

      it "renders with custom ID" do
        render_inline(test_component_class.new(text: "Button", id: "my-button"))

        expect(page).to have_css("button#my-button")
      end
    end
  end

  describe "slots" do
    it "renders with icon_leading slot" do
      component = test_component_class.new(text: "Button")

      render_inline(component) do |c|
        c.with_icon_leading { '<svg class="icon-leading"></svg>'.html_safe }
      end

      expect(page).to have_css("button .icon-leading")
    end

    it "renders with icon_trailing slot" do
      component = test_component_class.new(text: "Button")

      render_inline(component) do |c|
        c.with_icon_trailing { '<svg class="icon-trailing"></svg>'.html_safe }
      end

      expect(page).to have_css("button .icon-trailing")
    end

    it "renders with both icon slots" do
      component = test_component_class.new(text: "Button")

      render_inline(component) do |c|
        c.with_icon_leading { '<svg class="icon-leading"></svg>'.html_safe }
        c.with_icon_trailing { '<svg class="icon-trailing"></svg>'.html_safe }
      end

      expect(page).to have_css("button .icon-leading")
      expect(page).to have_css("button .icon-trailing")
    end
  end

  describe "#disabled?" do
    it "returns true when disabled is true" do
      component = test_component_class.new(text: "Button", disabled: true)

      expect(component.send(:disabled?)).to be true
    end

    it "returns false when disabled is false" do
      component = test_component_class.new(text: "Button", disabled: false)

      expect(component.send(:disabled?)).to be false
    end
  end

  describe "edge cases" do
    it "combines multiple configuration options" do
      render_inline(test_component_class.new(
        text: "Submit",
        variant: :primary,
        size: :large,
        disabled: true,
        full_width: true,
        class: "custom-btn",
        id: "submit-btn"
      ))

      # Verify button renders with text and ID
      expect(page).to have_button("Submit")
      expect(page).to have_css("button#submit-btn")
      # Classes should be present in the element's class attribute
      button = page.find("button")
      expect(button[:class]).to include("custom-btn")
    end

    it "handles special characters in text" do
      render_inline(test_component_class.new(text: "Click & Save"))

      expect(page).to have_button("Click & Save")
    end

    it "renders all variant and size combinations" do
      described_class::VARIANTS.each do |variant|
        described_class::SIZES.each do |size|
          expect {
            render_inline(test_component_class.new(text: "Button", variant: variant, size: size))
          }.not_to raise_error
        end
      end
    end
  end
end
