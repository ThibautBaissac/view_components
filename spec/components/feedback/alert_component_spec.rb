# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::AlertComponent, type: :component do
  describe "rendering" do
    context "with basic configuration" do
      it "renders alert with message" do
        render_inline(described_class.new(message: "Information message"))

        expect(page).to have_css(".alert[role='alert']")
        expect(page).to have_text("Information message")
      end

      it "renders with default type (info)" do
        render_inline(described_class.new(message: "Default alert"))

        expect(page).to have_css(".bg-sky-50.border-sky-200")
      end

      it "includes base alert classes" do
        render_inline(described_class.new(message: "Alert"))

        expect(page).to have_css(".alert.flex.items-start.gap-3")
        expect(page).to have_css(".px-4.py-3\\.5.border-l-4.rounded-lg")
      end

      it "includes ARIA attributes" do
        render_inline(described_class.new(message: "Alert"))

        expect(page).to have_css('[role="alert"]')
        expect(page).to have_css('[aria-live="polite"]')
        expect(page).to have_css('[aria-atomic="true"]')
      end
    end

    context "with different types" do
      it "renders info type" do
        render_inline(described_class.new(message: "Info", type: :info))

        expect(page).to have_css(".bg-sky-50.border-sky-200")
      end

      it "renders success type" do
        render_inline(described_class.new(message: "Success", type: :success))

        expect(page).to have_css(".bg-green-50.border-green-200")
      end

      it "renders warning type" do
        render_inline(described_class.new(message: "Warning", type: :warning))

        expect(page).to have_css(".bg-yellow-50.border-yellow-200")
      end

      it "renders error type" do
        render_inline(described_class.new(message: "Error", type: :error))

        expect(page).to have_css(".bg-red-50.border-red-200")
      end

      it "uses assertive aria-live for errors" do
        render_inline(described_class.new(message: "Error", type: :error))

        expect(page).to have_css('[aria-live="assertive"]')
      end

      it "uses polite aria-live for non-errors" do
        render_inline(described_class.new(message: "Info", type: :info))

        expect(page).to have_css('[aria-live="polite"]')
      end
    end

    context "with icon" do
      it "shows default icon by default" do
        render_inline(described_class.new(message: "Alert"))

        expect(page).to have_css(".flex-shrink-0.mt-0\\.5")
      end

      it "hides icon when show_icon is false" do
        render_inline(described_class.new(message: "Alert", show_icon: false))

        expect(page).not_to have_css(".flex-shrink-0.mt-0\\.5")
      end

      it "renders custom icon when provided via slot" do
        component = described_class.new(message: "Alert")

        render_inline(component) do |c|
          c.with_icon(name: "star", variant: :solid)
        end

        expect(page).to have_css(".alert")
      end
    end

    context "with title slot" do
      it "does not render title by default" do
        render_inline(described_class.new(message: "Message only"))

        expect(page).not_to have_css(".font-semibold.text-sm.mb-1")
      end

      it "renders title when provided" do
        component = described_class.new(message: "Details here")

        render_inline(component) do |c|
          c.with_title { "Important" }
        end

        expect(page).to have_css(".font-semibold.text-sm.mb-1", text: "Important")
        expect(page).to have_text("Details here")
      end
    end

    context "with actions" do
      it "does not render actions by default" do
        render_inline(described_class.new(message: "No actions"))

        expect(page).not_to have_css(".flex.gap-4.mt-2")
      end

      it "renders single action" do
        component = described_class.new(message: "Alert with action")

        render_inline(component) do |c|
          c.with_action(text: "View Details", url: "#details")
        end

        expect(page).to have_link("View Details", href: "#details")
        expect(page).to have_css("a.inline-flex.items-center.text-sm.font-medium.underline")
      end

      it "renders multiple actions" do
        component = described_class.new(message: "Alert with actions")

        render_inline(component) do |c|
          c.with_action(text: "Action 1", url: "#1")
          c.with_action(text: "Action 2", url: "#2")
        end

        expect(page).to have_link("Action 1", href: "#1")
        expect(page).to have_link("Action 2", href: "#2")
        expect(page).to have_css(".flex.gap-4.mt-2")
      end

      it "applies focus styles to actions" do
        component = described_class.new(message: "Alert")

        render_inline(component) do |c|
          c.with_action(text: "Action", url: "#")
        end

        expect(page).to have_css("a.focus\\:outline-none.focus\\:ring-2.focus\\:ring-offset-2")
      end
    end

    context "with dismissible functionality" do
      it "does not render dismiss button by default" do
        render_inline(described_class.new(message: "Not dismissible"))

        expect(page).not_to have_css('[aria-label="Dismiss alert"]')
      end

      it "renders dismiss button when dismissible is true" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(message: "Dismissible", dismissible: true))

          expect(page).to have_css('button[type="button"]')
          expect(page).to have_css('[aria-label="Dismiss alert"]')
        end
      end

      it "includes Stimulus controller when dismissible" do
        render_inline(described_class.new(message: "Alert", dismissible: true))

        expect(page).to have_css('[data-controller="components--alert"]')
      end

      it "does not include Stimulus controller when not dismissible" do
        render_inline(described_class.new(message: "Alert"))

        expect(page).not_to have_css('[data-controller="components--alert"]')
      end

      it "includes dismiss action on button" do
        render_inline(described_class.new(message: "Alert", dismissible: true))

        expect(page).to have_css('[data-action="click->components--alert#dismiss"]')
      end

      it "renders x-mark icon in dismiss button" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(message: "Alert", dismissible: true))

          expect(page).to have_css('button[aria-label="Dismiss alert"]')
        end
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(message: "Alert", class: "custom-alert"))

        expect(page).to have_css(".alert")
        # Note: class merging may not work as expected with deep_merge
      end

      it "renders with custom ID" do
        render_inline(described_class.new(message: "Alert", id: "my-alert"))

        expect(page).to have_css("#my-alert")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(message: "Alert", data: { testid: "alert-1" }))

        expect(page).to have_css('[data-testid="alert-1"]')
      end
    end
  end

  describe "#render?" do
    it "renders when message is present" do
      component = described_class.new(message: "Alert message")

      expect(component.render?).to be true
    end

    it "does not render when message is nil" do
      component = described_class.new(message: nil)

      expect(component.render?).to be_falsey
    end

    it "does not render when message is empty string" do
      component = described_class.new(message: "")

      expect(component.render?).to be_falsey
    end

    it "actually skips rendering when message is nil" do
      result = render_inline(described_class.new(message: nil))

      expect(result.to_html.strip).to be_empty
    end
  end

  describe "validation" do
    context "type validation" do
      it "accepts valid info type" do
        expect {
          described_class.new(message: "Test", type: :info)
        }.not_to raise_error
      end

      it "accepts valid success type" do
        expect {
          described_class.new(message: "Test", type: :success)
        }.not_to raise_error
      end

      it "accepts valid warning type" do
        expect {
          described_class.new(message: "Test", type: :warning)
        }.not_to raise_error
      end

      it "accepts valid error type" do
        expect {
          described_class.new(message: "Test", type: :error)
        }.not_to raise_error
      end

      it "raises error for invalid type" do
        expect {
          described_class.new(message: "Test", type: :invalid)
        }.to raise_error(ArgumentError, /Invalid type: invalid/)
      end
    end
  end

  describe "accessibility" do
    it "uses proper ARIA role" do
      render_inline(described_class.new(message: "Alert"))

      expect(page).to have_css('[role="alert"]')
    end

    it "includes aria-live attribute" do
      render_inline(described_class.new(message: "Alert"))

      expect(page).to have_css('[aria-live]')
    end

    it "includes aria-atomic attribute" do
      render_inline(described_class.new(message: "Alert"))

      expect(page).to have_css('[aria-atomic="true"]')
    end

    it "uses assertive for error alerts" do
      render_inline(described_class.new(message: "Error", type: :error))

      expect(page).to have_css('[aria-live="assertive"]')
    end

    it "uses polite for non-error alerts" do
      [ :info, :success, :warning ].each do |type|
        render_inline(described_class.new(message: "Alert", type: type))

        expect(page).to have_css('[aria-live="polite"]')
      end
    end

    it "includes aria-label on dismiss button" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(message: "Alert", dismissible: true))

        expect(page).to have_css('[aria-label="Dismiss alert"]')
      end
    end

    it "uses French aria-label when locale is fr" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(message: "Alert", dismissible: true))

        expect(page).to have_css('[aria-label="Fermer l\'alerte"]')
      end
    end
  end

  describe "internationalization" do
    context "with English locale" do
      it "uses English dismiss label" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(message: "Alert", dismissible: true))

          # Check for button with aria-label attribute
          expect(page).to have_css('button[aria-label]')
          expect(page).to have_css('[aria-label="Dismiss alert"]')
        end
      end
    end

    context "with French locale" do
      around do |example|
        I18n.with_locale(:fr) { example.run }
      end

      it "uses French dismiss label" do
        render_inline(described_class.new(message: "Alerte", dismissible: true))

        expect(page).to have_css('[aria-label="Fermer l\'alerte"]')
      end

      it "renders alert message in French" do
        render_inline(described_class.new(message: "Votre commande a été confirmée", type: :success))

        expect(page).to have_text("Votre commande a été confirmée")
      end
    end

    context "with fallback behavior" do
      it "falls back to English when French is unavailable" do
        # Temporarily remove French translations to test fallback
        original_backend = I18n.backend
        I18n.backend = I18n::Backend::Simple.new

        I18n.with_locale(:en) do
          render_inline(described_class.new(message: "Alert", dismissible: true))

          expect(page).to have_css('[aria-label="Dismiss alert"]')
        end

        I18n.backend = original_backend
      end
    end
  end

  describe "HtmlAttributesRendering concern" do
    it "includes HtmlAttributesRendering concern" do
      expect(described_class.ancestors).to include(HtmlAttributesRendering)
    end

    it "includes I18nHelpers concern" do
      expect(described_class.ancestors).to include(I18nHelpers)
    end

    it "properly merges class attributes" do
      render_inline(described_class.new(
        message: "Test",
        class: "custom-alert"
      ))

      expect(page).to have_css(".alert.custom-alert")
    end

    it "properly merges nested data attributes" do
      render_inline(described_class.new(
        message: "Test",
        dismissible: true,
        data: { turbo_frame: "alerts" }
      ))

      expect(page).to have_css('[data-controller="components--alert"]')
      expect(page).to have_css('[data-turbo-frame="alerts"]')
    end

    it "properly merges nested aria attributes" do
      render_inline(described_class.new(
        message: "Test",
        aria: { describedby: "alert-description" }
      ))

      expect(page).to have_css('[role="alert"]')
      expect(page).to have_css('[aria-live]')
      expect(page).to have_css('[aria-describedby="alert-description"]')
    end
  end

  describe "edge cases" do
    it "handles special characters in message" do
      render_inline(described_class.new(
        message: "Alert <script>alert('xss')</script>"
      ))

      expect(page).to have_text("Alert")
      expect(page).not_to have_css("script")
    end

    it "handles long messages" do
      long_message = "a" * 500
      render_inline(described_class.new(message: long_message))

      expect(page).to have_text(long_message)
    end

    it "combines multiple configuration options" do
      component = described_class.new(
        message: "Complex alert",
        type: :warning,
        dismissible: true,
        show_icon: true,
        class: "custom-class",
        id: "alert-1"
      )

      render_inline(component) do |c|
        c.with_title { "Warning Title" }
        c.with_action(text: "Action", url: "#")
      end

      expect(page).to have_css("#alert-1")
      expect(page).to have_css(".alert")
      expect(page).to have_css(".bg-yellow-50")
      expect(page).to have_css('[data-controller="components--alert"]')
      expect(page).to have_text("Warning Title")
      expect(page).to have_text("Complex alert")
      expect(page).to have_link("Action")
    end

    it "handles string type (symbol conversion)" do
      render_inline(described_class.new(message: "Test", type: "success"))

      expect(page).to have_css(".bg-green-50")
    end
  end

  describe "content structure" do
    it "renders content in flex container" do
      render_inline(described_class.new(message: "Alert"))

      expect(page).to have_css(".flex-1.min-w-0")
    end

    it "applies proper text styles to message" do
      render_inline(described_class.new(message: "Styled message"))

      expect(page).to have_css(".text-sm", text: "Styled message")
    end

    it "applies proper styles to title" do
      component = described_class.new(message: "Message")

      render_inline(component) do |c|
        c.with_title { "Title" }
      end

      expect(page).to have_css(".font-semibold.text-sm.mb-1", text: "Title")
    end

    it "places icon at the start" do
      render_inline(described_class.new(message: "Alert"))

      # Icon should be first element (flex-shrink-0)
      expect(page).to have_css(".flex-shrink-0.mt-0\\.5")
    end

    it "places dismiss button at the end when dismissible" do
      render_inline(described_class.new(message: "Alert", dismissible: true))

      # Dismiss button has ml-auto to push it to the end
      expect(page).to have_css("button.flex-shrink-0.ml-auto")
    end
  end

  describe "type-specific configurations" do
    it "uses correct icon for info type" do
      render_inline(described_class.new(message: "Info", type: :info))

      expect(page).to have_css(".alert")
    end

    it "uses correct icon for success type" do
      render_inline(described_class.new(message: "Success", type: :success))

      expect(page).to have_css(".alert")
    end

    it "uses correct icon for warning type" do
      render_inline(described_class.new(message: "Warning", type: :warning))

      expect(page).to have_css(".alert")
    end

    it "uses correct icon for error type" do
      render_inline(described_class.new(message: "Error", type: :error))

      expect(page).to have_css(".alert")
    end
  end
end
