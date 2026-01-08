# frozen_string_literal: true

require "rails_helper"

RSpec.describe Behavior::ClipboardComponent, type: :component do
  describe "rendering" do
    context "with basic configuration" do
      it "renders a clipboard button with default settings" do
        render_inline(described_class.new(value: "text to copy"))

        expect(page).to have_css('[data-controller="components--clipboard"]')
        expect(page).to have_css('[data-components--clipboard-target="source"][value="text to copy"]', visible: :hidden)
        expect(page).to have_button(type: "button")
        expect(page).to have_css('[data-action="click->components--clipboard#copy"]')
      end

      it "renders with custom text" do
        render_inline(described_class.new(value: "text to copy", text: "Copy URL"))

        expect(page).to have_css('[data-components--clipboard-target="text"]', text: "Copy URL")
      end

      it "renders with default 'Copier' text when not specified" do
        render_inline(described_class.new(value: "text to copy"))

        expect(page).to have_css('[data-components--clipboard-target="text"]', text: "Copier")
      end

      it "renders with custom success text" do
        render_inline(described_class.new(value: "text", success_text: "Copié avec succès!"))

        expect(page).to have_css('[data-components--clipboard-success-text-value="Copié avec succès!"]')
        expect(page).to have_css('[data-components--clipboard-target="successText"]', text: "Copié avec succès!")
      end

      it "renders with default 'Copié !' text when not specified" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_css('[data-components--clipboard-success-text-value="Copié !"]')
      end

      it "renders with custom success duration" do
        render_inline(described_class.new(value: "text", success_duration: 3000))

        expect(page).to have_css('[data-components--clipboard-success-duration-value="3000"]')
      end

      it "renders with default 2000ms duration when not specified" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_css('[data-components--clipboard-success-duration-value="2000"]')
      end
    end

    context "with button variant" do
      it "renders button variant by default" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_button(type: "button")
        expect(page).to have_css('[data-components--clipboard-target="text"]')
        expect(page).to have_css('[data-components--clipboard-target="icon"]')
        expect(page).to have_css('[data-components--clipboard-target="successText"]')
        expect(page).to have_css('[data-components--clipboard-target="successIcon"]')
      end

      it "renders with primary button variant" do
        render_inline(described_class.new(value: "text", button_variant: :primary))

        expect(page).to have_css('button.bg-blue-600.text-white')
        expect(page).to have_css('button.hover\:bg-blue-700')
        expect(page).to have_css('button.focus\:ring-blue-500')
      end

      it "renders with secondary button variant" do
        render_inline(described_class.new(value: "text", button_variant: :secondary))

        expect(page).to have_css('button.bg-gray-600.text-white')
        expect(page).to have_css('button.hover\:bg-gray-700')
        expect(page).to have_css('button.focus\:ring-gray-500')
      end

      it "renders with outline button variant (default)" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_css('button.border-2.border-gray-300')
        expect(page).to have_css('button.text-gray-700')
        expect(page).to have_css('button.hover\:bg-gray-50')
      end

      it "renders with ghost button variant" do
        render_inline(described_class.new(value: "text", button_variant: :ghost))

        expect(page).to have_css('button.text-gray-700')
        expect(page).to have_css('button.hover\:bg-gray-100')
      end

      it "renders with small button size" do
        render_inline(described_class.new(value: "text", button_size: :small))

        expect(page).to have_css('button.px-3.py-1\.5.text-sm.rounded')
      end

      it "renders with medium button size (default)" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_css('button.px-4.py-2.text-base.rounded-md')
      end

      it "renders with large button size" do
        render_inline(described_class.new(value: "text", button_size: :large))

        expect(page).to have_css('button.px-6.py-3.text-lg.rounded-lg')
      end

      it "includes base button classes" do
        render_inline(described_class.new(value: "text"))

        expect(page).to have_css('button.inline-flex.items-center.justify-center.gap-2')
        expect(page).to have_css('button.font-medium.transition-all.duration-200')
        expect(page).to have_css('button.focus\:outline-none.focus\:ring-2.focus\:ring-offset-2')
      end
    end

    context "with icon variant" do
      it "renders icon-only variant" do
        render_inline(described_class.new(value: "text", variant: :icon))

        expect(page).to have_button(type: "button")
        expect(page).not_to have_css('[data-components--clipboard-target="text"]')
        expect(page).to have_css('[data-components--clipboard-target="icon"]')
        expect(page).to have_css('[data-components--clipboard-target="successIcon"]')
      end

      it "renders with proper icon classes" do
        render_inline(described_class.new(value: "text", variant: :icon))

        expect(page).to have_css('button.inline-flex.items-center.justify-center.p-2')
        expect(page).to have_css('button.text-gray-500.hover\:text-gray-700')
        expect(page).to have_css('button.hover\:bg-gray-100.rounded-md.transition-colors')
      end

      it "includes aria-label for accessibility" do
        render_inline(described_class.new(value: "text", variant: :icon, text: "Copy URL"))

        expect(page).to have_css('button[aria-label="Copy URL"]')
      end

      it "includes default aria-label when text not specified" do
        render_inline(described_class.new(value: "text", variant: :icon))

        expect(page).to have_css('button[aria-label="Copier"]')
      end
    end

    context "with custom trigger slot" do
      it "renders custom trigger content" do
        component = described_class.new(value: "text to copy")

        render_inline(component) do |c|
          c.with_trigger { '<span class="custom-trigger">Click me</span>'.html_safe }
        end

        expect(page).to have_css('.custom-trigger', text: "Click me")
        expect(page).to have_css('[data-action="click->components--clipboard#copy"]')
        expect(page).not_to have_button
      end

      it "uses custom trigger instead of default button" do
        component = described_class.new(value: "text", variant: :button)

        render_inline(component) do |c|
          c.with_trigger { '<a href="#" class="link-trigger">Copy link</a>'.html_safe }
        end

        expect(page).to have_css('a.link-trigger')
        expect(page).not_to have_css('button')
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(value: "text", class: "custom-wrapper"))

        expect(page).to have_css('.inline-flex.custom-wrapper')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(value: "text", data: { testid: "clipboard-btn" }))

        expect(page).to have_css('[data-testid="clipboard-btn"]')
      end

      it "renders with custom ID" do
        render_inline(described_class.new(value: "text", id: "my-clipboard"))

        expect(page).to have_css('#my-clipboard')
      end
    end
  end

  describe "#render?" do
    it "renders when value is present" do
      component = described_class.new(value: "text to copy")

      expect(component.render?).to be true
    end

    it "does not render when value is nil" do
      component = described_class.new(value: nil)

      expect(component.render?).to be false
    end

    it "renders when value is an empty string" do
      component = described_class.new(value: "")

      expect(component.render?).to be true
    end

    it "actually skips rendering when value is nil" do
      result = render_inline(described_class.new(value: nil))

      expect(result.to_html.strip).to be_empty
    end
  end

  describe "validation" do
    context "variant validation" do
      it "accepts valid button variant" do
        expect {
          described_class.new(value: "text", variant: :button)
        }.not_to raise_error
      end

      it "accepts valid icon variant" do
        expect {
          described_class.new(value: "text", variant: :icon)
        }.not_to raise_error
      end

      it "raises error for invalid variant" do
        expect {
          described_class.new(value: "text", variant: :invalid)
        }.to raise_error(ArgumentError, /Invalid variant: invalid. Valid variants are: button, icon/)
      end
    end

    context "button_variant validation" do
      it "accepts valid primary variant" do
        expect {
          described_class.new(value: "text", button_variant: :primary)
        }.not_to raise_error
      end

      it "accepts valid secondary variant" do
        expect {
          described_class.new(value: "text", button_variant: :secondary)
        }.not_to raise_error
      end

      it "accepts valid outline variant" do
        expect {
          described_class.new(value: "text", button_variant: :outline)
        }.not_to raise_error
      end

      it "accepts valid ghost variant" do
        expect {
          described_class.new(value: "text", button_variant: :ghost)
        }.not_to raise_error
      end

      it "raises error for invalid button_variant" do
        expect {
          described_class.new(value: "text", button_variant: :invalid)
        }.to raise_error(ArgumentError, /Invalid button_variant: invalid. Valid variants are: primary, secondary, outline, ghost/)
      end
    end

    context "button_size validation" do
      it "accepts valid small size" do
        expect {
          described_class.new(value: "text", button_size: :small)
        }.not_to raise_error
      end

      it "accepts valid medium size" do
        expect {
          described_class.new(value: "text", button_size: :medium)
        }.not_to raise_error
      end

      it "accepts valid large size" do
        expect {
          described_class.new(value: "text", button_size: :large)
        }.not_to raise_error
      end

      it "raises error for invalid button_size" do
        expect {
          described_class.new(value: "text", button_size: :invalid)
        }.to raise_error(ArgumentError, /Invalid button_size: invalid. Valid sizes are: small, medium, large/)
      end
    end
  end

  describe "accessibility" do
    it "includes screen reader announcement area" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('.sr-only[role="status"][aria-live="polite"]')
      expect(page).to have_css('[data-components--clipboard-target="announcement"]')
    end

    it "includes proper button focus styles" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('button.focus\:outline-none.focus\:ring-2.focus\:ring-offset-2')
    end

    it "includes aria-label for icon variant" do
      render_inline(described_class.new(value: "text", variant: :icon))

      expect(page).to have_css('button[aria-label]')
    end

    it "hides success elements initially" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('[data-components--clipboard-target="successIcon"].hidden')
      expect(page).to have_css('[data-components--clipboard-target="successText"].hidden')
    end

    it "includes proper ARIA attributes on hidden input" do
      render_inline(described_class.new(value: "sensitive data"))

      expect(page).to have_css('input[type="hidden"]', visible: :hidden)
    end
  end

  describe "Stimulus controller integration" do
    it "includes Stimulus controller" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('[data-controller="components--clipboard"]')
    end

    it "includes all required Stimulus targets" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('[data-components--clipboard-target="source"]', visible: :hidden)
      expect(page).to have_css('[data-components--clipboard-target="button"]')
      expect(page).to have_css('[data-components--clipboard-target="icon"]')
      expect(page).to have_css('[data-components--clipboard-target="successIcon"]')
      expect(page).to have_css('[data-components--clipboard-target="text"]')
      expect(page).to have_css('[data-components--clipboard-target="successText"]')
      expect(page).to have_css('[data-components--clipboard-target="announcement"]')
    end

    it "includes Stimulus action binding" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('[data-action="click->components--clipboard#copy"]')
    end

    it "includes Stimulus values" do
      render_inline(described_class.new(
        value: "text",
        success_text: "Done!",
        success_duration: 3000
      ))

      expect(page).to have_css('[data-components--clipboard-success-text-value="Done!"]')
      expect(page).to have_css('[data-components--clipboard-success-duration-value="3000"]')
    end

    it "includes i18n announcement values for screen readers" do
      render_inline(described_class.new(value: "text"))

      expect(page).to have_css('[data-components--clipboard-success-announcement-value="Copié dans le presse-papiers"]')
      expect(page).to have_css('[data-components--clipboard-error-announcement-value="Échec de la copie dans le presse-papiers"]')
    end
  end

  describe "icon rendering" do
    it "renders clipboard icon in default state" do
      render_inline(described_class.new(value: "text"))

      # Foundation::IconComponent should be rendered
      expect(page).to have_css('[data-components--clipboard-target="icon"]')
    end

    it "renders success check icon" do
      render_inline(described_class.new(value: "text"))

      # Success icon (hidden by default)
      expect(page).to have_css('[data-components--clipboard-target="successIcon"]')
    end
  end

  describe "edge cases" do
    it "handles special characters in value" do
      special_value = 'text with "quotes" and <tags>'
      render_inline(described_class.new(value: special_value))

      expect(page).to have_css("[value='#{special_value}']", visible: :hidden)
    end

    it "handles multiline value" do
      multiline = "Line 1\nLine 2\nLine 3"
      render_inline(described_class.new(value: multiline))

      expect(page).to have_css('[data-components--clipboard-target="source"]', visible: :hidden)
    end

    it "handles long value" do
      long_value = "a" * 1000
      render_inline(described_class.new(value: long_value))

      expect(page).to have_css('[data-components--clipboard-target="source"]', visible: :hidden)
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        value: "https://example.com",
        text: "Copy URL",
        success_text: "URL copied!",
        success_duration: 3000,
        variant: :button,
        button_variant: :primary,
        button_size: :large,
        class: "my-clipboard",
        id: "url-clipboard"
      ))

      expect(page).to have_css('#url-clipboard.my-clipboard')
      expect(page).to have_css('button.bg-blue-600.px-6.py-3.text-lg')
      expect(page).to have_css('[data-components--clipboard-target="text"]', text: "Copy URL")
      expect(page).to have_css('[data-components--clipboard-success-text-value="URL copied!"]')
      expect(page).to have_css('[data-components--clipboard-success-duration-value="3000"]')
    end
  end
end
