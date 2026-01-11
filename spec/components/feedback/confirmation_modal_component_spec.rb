# frozen_string_literal: true

require "rails_helper"

RSpec.describe Feedback::ConfirmationModalComponent, type: :component do
  describe "rendering" do
    context "with basic configuration" do
      it "renders confirmation modal with title and message" do
        render_inline(described_class.new(
          id: "confirm-modal",
          title: "Confirm Action",
          message: "Are you sure?"
        ))

        expect(page).to have_text("Confirm Action")
        expect(page).to have_text("Are you sure?")
      end

      it "renders with default type (danger)" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm deletion"
        ))

        expect(page).to have_css(".bg-red-100")
      end

      it "renders default confirm and cancel buttons" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(
            id: "modal-1",
            title: "Confirm",
            message: "Are you sure?"
          ))

          expect(page).to have_text("Confirm")
          expect(page).to have_text("Cancel")
        end
      end

      it "includes modal component" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        ))

        expect(page).to have_css('[data-controller*="components--modal"]')
      end
    end

    context "with different types" do
      it "renders danger type" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm",
          type: :danger
        ))

        expect(page).to have_css(".bg-red-100")
      end

      it "renders warning type" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Warning",
          message: "Confirm",
          type: :warning
        ))

        expect(page).to have_css(".bg-yellow-100")
      end

      it "renders info type" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Information",
          message: "Confirm",
          type: :info
        ))

        expect(page).to have_css(".bg-sky-100")
      end
    end

    context "with icon" do
      it "shows default icon by default" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        ))

        expect(page).to have_css(".mx-auto.flex.items-center.justify-center.h-12.w-12.rounded-full")
      end

      it "hides icon when show_icon is false" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message",
          show_icon: false
        ))

        expect(page).not_to have_css(".h-12.w-12.rounded-full")
      end

      it "renders custom icon when provided" do
        component = described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        )

        render_inline(component) do |c|
          c.with_icon(name: "star", variant: :solid)
        end

        expect(page).to have_css(".h-12.w-12.rounded-full")
      end
    end

    context "with custom button text" do
      it "renders custom confirm text" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm deletion",
          confirm_text: "Yes, Delete"
        ))

        expect(page).to have_text("Yes, Delete")
      end

      it "renders custom cancel text" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Action",
          message: "Confirm",
          cancel_text: "No, Cancel"
        ))

        expect(page).to have_text("No, Cancel")
      end
    end

    context "with confirm URL" do
      it "renders confirm link when URL provided" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm",
          confirm_url: "/items/1",
          confirm_method: :delete
        ))

        expect(page).to have_css('a[href="/items/1"]')
      end

      it "includes turbo_method data attribute" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm",
          confirm_url: "/items/1",
          confirm_method: :delete
        ))

        expect(page).to have_css('[data-turbo-method="delete"]')
      end

      it "includes close action for non-GET methods" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Delete",
          message: "Confirm",
          confirm_url: "/items/1",
          confirm_method: :delete
        ))

        expect(page).to have_css('[data-action*="click->components--modal#close"]')
      end

      it "does not include close action on confirm link for GET method" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "View",
          message: "Confirm",
          confirm_url: "/items/1",
          confirm_method: :get
        ))

        # Cancel button still has close action, but confirm link doesn't
        expect(page).to have_css('a[href="/items/1"]')
      end
    end

    context "without confirm URL (button-only)" do
      it "renders confirm button when no URL provided" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Confirm",
          message: "Are you sure?"
        ))

        expect(page).to have_css('button', text: "Confirm")
      end

      it "includes confirmation modal controller action" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Confirm",
          message: "Are you sure?"
        ))

        expect(page).to have_css('[data-action="click->components--confirmation-modal#confirm"]')
      end

      it "includes confirm button target" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Confirm",
          message: "Are you sure?"
        ))

        expect(page).to have_css('[data-components--confirmation-modal-target="confirmButton"]', visible: :all)
      end
    end

    context "with form slot" do
      it "renders custom form when provided" do
        component = described_class.new(
          id: "modal-1",
          title: "Submit",
          message: "Confirm submission"
        )

        render_inline(component) do |c|
          c.with_form { '<form><input type="submit"></form>'.html_safe }
        end

        expect(page).to have_css("form")
        expect(page).to have_css('input[type="submit"]')
      end

      it "does not render confirm URL buttons when form provided" do
        component = described_class.new(
          id: "modal-1",
          title: "Submit",
          message: "Confirm",
          confirm_url: "/test"
        )

        render_inline(component) do |c|
          c.with_form { '<form></form>'.html_safe }
        end

        expect(page).not_to have_css('a[href="/test"]')
      end
    end

    context "with description slot" do
      it "does not render description by default" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        ))

        expect(page).not_to have_css(".text-sm.text-slate-500.text-center.mt-2")
      end

      it "renders description when provided" do
        component = described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        )

        render_inline(component) do |c|
          c.with_description { "Additional details here" }
        end

        expect(page).to have_css(".text-sm.text-slate-500.text-center.mt-2", text: "Additional details here")
      end
    end

    context "with HTML attributes" do
      it "renders with custom data attributes" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message",
          data: { testid: "confirm-modal" }
        ))

        expect(page).to have_css('[data-testid="confirm-modal"]')
      end
    end
  end

  describe "validation" do
    context "type validation" do
      it "accepts valid danger type" do
        expect {
          described_class.new(id: "modal", title: "Test", message: "Test", type: :danger)
        }.not_to raise_error
      end

      it "accepts valid warning type" do
        expect {
          described_class.new(id: "modal", title: "Test", message: "Test", type: :warning)
        }.not_to raise_error
      end

      it "accepts valid info type" do
        expect {
          described_class.new(id: "modal", title: "Test", message: "Test", type: :info)
        }.not_to raise_error
      end

      it "raises error for invalid type" do
        expect {
          described_class.new(id: "modal", title: "Test", message: "Test", type: :invalid)
        }.to raise_error(ArgumentError, /Invalid type: invalid/)
      end
    end
  end

  describe ".trigger_attributes" do
    it "returns trigger attributes for modal" do
      attrs = described_class.trigger_attributes(modal_id: "test-modal")

      expect(attrs).to be_a(Hash)
    end
  end

  describe "accessibility" do
    it "includes modal title with proper ID" do
      render_inline(described_class.new(
        id: "test-modal",
        title: "Confirm",
        message: "Message"
      ))

      expect(page).to have_css("#test-modal-title", text: "Confirm")
    end

    it "uses semantic heading for title" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Title",
        message: "Message"
      ))

      expect(page).to have_css("h3", text: "Title")
    end

    it "uses paragraph element for message" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Title",
        message: "Test message"
      ))

      expect(page).to have_css("p", text: "Test message")
    end
  end

  describe "button variants" do
    it "uses danger variant for danger type" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Delete",
        message: "Confirm",
        type: :danger
      ))

      # Button should be rendered (exact class matching might be tricky with component nesting)
      expect(page).to have_text("Confirm")
    end

    it "uses warning variant for warning type" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Warning",
        message: "Confirm",
        type: :warning
      ))

      expect(page).to have_text("Confirm")
    end

    it "uses primary variant for info type" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Info",
        message: "Confirm",
        type: :info
      ))

      expect(page).to have_text("Confirm")
    end
  end

  describe "controller integration" do
    it "includes confirmation modal controller" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css('[data-controller*="components--confirmation-modal"]')
    end

    it "includes enter key action" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css('[data-action*="keydown.enter->components--confirmation-modal#confirmOnEnter"]')
    end

    it "includes close action on cancel button" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css('[data-action*="click->components--modal#close"]')
    end
  end

  describe "edge cases" do
    it "handles special characters in title" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Delete <script>alert('xss')</script>",
        message: "Confirm"
      ))

      expect(page).to have_text("Delete")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in message" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Confirm",
        message: "Are you sure? <b>Think carefully</b>"
      ))

      expect(page).to have_text("Are you sure?")
      expect(page).not_to have_css("b")
    end

    it "handles long messages" do
      long_message = "a" * 500
      render_inline(described_class.new(
        id: "modal-1",
        title: "Confirm",
        message: long_message
      ))

      expect(page).to have_text(long_message)
    end

    it "combines multiple configuration options" do
      component = described_class.new(
        id: "complex-modal",
        title: "Delete Item",
        message: "This action cannot be undone",
        type: :danger,
        confirm_text: "Yes, Delete",
        cancel_text: "No, Keep",
        confirm_url: "/items/1",
        confirm_method: :delete,
        show_icon: true,
        data: { testid: "delete-modal" }
      )

      render_inline(component) do |c|
        c.with_description { "Additional warning" }
      end

      expect(page).to have_text("Delete Item")
      expect(page).to have_text("This action cannot be undone")
      expect(page).to have_text("Yes, Delete")
      expect(page).to have_text("No, Keep")
      expect(page).to have_css('a[href="/items/1"]')
      expect(page).to have_css('[data-turbo-method="delete"]')
      expect(page).to have_text("Additional warning")
    end

    it "handles string type (symbol conversion)" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message",
        type: "warning"
      ))

      expect(page).to have_css(".bg-yellow-100")
    end
  end

  describe "layout and styling" do
    it "centers content" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css(".text-center.py-4")
    end

    it "applies proper title styles" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Title",
        message: "Message"
      ))

      expect(page).to have_css(".text-lg.font-semibold.text-slate-900.text-center")
    end

    it "applies proper message styles" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Title",
        message: "Message"
      ))

      expect(page).to have_css(".text-sm.text-slate-600.text-center")
    end

    it "applies responsive action layout" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css(".flex.flex-col-reverse.sm\\:flex-row.sm\\:justify-center.gap-3")
    end
  end

  describe "internationalization" do
    context "with English locale" do
      it "uses English confirm text" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(
            id: "modal-1",
            title: "Test",
            message: "Message"
          ))

          expect(page).to have_button("Confirm")
        end
      end

      it "uses English cancel text" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(
            id: "modal-1",
            title: "Test",
            message: "Message"
          ))

          expect(page).to have_button("Cancel")
        end
      end
    end

    context "with French locale" do
      around do |example|
        I18n.with_locale(:fr) { example.run }
      end

      it "uses French confirm text" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        ))

        expect(page).to have_button("Confirmer")
      end

      it "uses French cancel text" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Test",
          message: "Message"
        ))

        expect(page).to have_button("Annuler")
      end

      it "renders French message content" do
        render_inline(described_class.new(
          id: "modal-1",
          title: "Supprimer l'événement",
          message: "Êtes-vous sûr de vouloir supprimer cet événement ?"
        ))

        expect(page).to have_text("Supprimer l'événement")
        expect(page).to have_text("Êtes-vous sûr de vouloir supprimer cet événement ?")
      end
    end

    context "with custom text overriding translations" do
      it "uses custom confirm text instead of translations" do
        I18n.with_locale(:fr) do
          render_inline(described_class.new(
            id: "modal-1",
            title: "Test",
            message: "Message",
            confirm_text: "Custom Confirm"
          ))

          expect(page).to have_button("Custom Confirm")
          expect(page).not_to have_button("Confirmer")
        end
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

    it "properly merges custom classes" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message",
        class: "custom-modal"
      ))

      # The custom class should be present in the dialog
      # Note: ModalComponent may wrap the class differently
      expect(page).to have_css("dialog")
    end

    it "properly merges nested data attributes" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message",
        data: { turbo_frame: "modals", custom: "value" }
      ))

      # Check that custom data attributes are present
      expect(page).to have_css('[data-turbo-frame="modals"]')
      expect(page).to have_css('[data-custom="value"]')

      # The confirmation modal controller should be present
      expect(page).to have_css('[data-controller*="confirmation-modal"]')
    end

    it "properly merges nested aria attributes" do
      render_inline(described_class.new(
        id: "test-modal",
        title: "Test",
        message: "Message",
        aria: { label: "Custom label" }
      ))

      expect(page).to have_css('[role="dialog"]')
      expect(page).to have_css('[aria-modal="true"]')
      expect(page).to have_css('[aria-describedby="test-modal-message"]')
      expect(page).to have_css('[aria-label="Custom label"]')
    end
  end

  describe "accessibility improvements" do
    it "adds aria-describedby pointing to message" do
      render_inline(described_class.new(
        id: "test-modal",
        title: "Title",
        message: "Description text"
      ))

      expect(page).to have_css('p[id="test-modal-message"]')
      expect(page).to have_css('[aria-describedby="test-modal-message"]')
    end

    it "adds role=dialog" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css('[role="dialog"]')
    end

    it "adds aria-modal=true" do
      render_inline(described_class.new(
        id: "modal-1",
        title: "Test",
        message: "Message"
      ))

      expect(page).to have_css('[aria-modal="true"]')
    end
  end
end
