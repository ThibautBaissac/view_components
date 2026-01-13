# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ModalComponent, type: :component do
  describe "basic rendering" do
    it "renders a dialog element with content" do
      render_inline(described_class.new(id: "test-modal", title: "Test Modal")) do
        "Modal content"
      end

      expect(page).to have_css("dialog#test-modal")
      expect(page).to have_css("div.modal-body", text: "Modal content")
    end

    it "applies modal controller" do
      render_inline(described_class.new(id: "test-modal")) { "Content" }

      expect(page).to have_css("dialog[data-controller='components--modal']")
    end

    it "sets aria-modal attribute" do
      render_inline(described_class.new(id: "test-modal")) { "Content" }

      expect(page).to have_css("dialog[aria-modal='true']")
    end

    it "sets aria-labelledby with modal ID" do
      render_inline(described_class.new(id: "my-modal", title: "Test")) { "Content" }

      expect(page).to have_css("dialog[aria-labelledby='my-modal-title']")
    end
  end

  describe "sizes" do
    it "renders medium size by default" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("dialog.max-w-lg")
    end

    it "renders small size" do
      render_inline(described_class.new(id: "modal", size: :small)) { "Content" }

      expect(page).to have_css("dialog.max-w-sm")
    end

    it "renders large size" do
      render_inline(described_class.new(id: "modal", size: :large)) { "Content" }

      expect(page).to have_css("dialog.max-w-2xl")
    end

    it "renders full size" do
      render_inline(described_class.new(id: "modal", size: :full)) { "Content" }

      expect(page).to have_css("dialog.max-w-4xl")
    end

    it "raises error for invalid size" do
      expect {
        described_class.new(id: "modal", size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size: invalid/)
    end

    it "accepts size as string" do
      render_inline(described_class.new(id: "modal", size: "large")) { "Content" }

      expect(page).to have_css("dialog.max-w-2xl")
    end
  end

  describe "dismissible behavior" do
    it "is dismissible by default" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("dialog[data-components--modal-dismissible-value='true']")
    end

    it "renders close button when dismissible" do
      render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }

      expect(page).to have_css("button[data-action='click->components--modal#close']")
    end

    it "does not render close button when not dismissible" do
      render_inline(described_class.new(id: "modal", title: "Test", dismissible: false)) { "Content" }

      expect(page).to have_no_css("button[data-action*='components--modal#close']")
    end

    it "sets dismissible value to false" do
      render_inline(described_class.new(id: "modal", dismissible: false)) { "Content" }

      expect(page).to have_css("dialog[data-components--modal-dismissible-value='false']")
    end
  end

  describe "open by default" do
    it "is closed by default" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_no_css("dialog[data-components--modal-open-value='true']")
    end

    it "sets open value when open is true" do
      render_inline(described_class.new(id: "modal", open: true)) { "Content" }

      expect(page).to have_css("dialog[data-components--modal-open-value='true']")
    end
  end

  describe "close on submit" do
    it "sets close_on_submit to true by default" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("dialog[data-components--modal-close-on-submit-value='true']")
    end

    it "sets close_on_submit to false" do
      render_inline(described_class.new(id: "modal", close_on_submit: false)) { "Content" }

      expect(page).to have_css("dialog[data-components--modal-close-on-submit-value='false']")
    end
  end

  describe "title rendering" do
    it "renders title in header" do
      render_inline(described_class.new(id: "modal", title: "My Modal")) { "Content" }

      expect(page).to have_css("h2#modal-title.text-xl.font-bold.text-slate-900", text: "My Modal")
    end

    it "does not render default title when custom header provided" do
      render_inline(described_class.new(id: "modal", title: "Default")) do |modal|
        modal.with_header { "<div>Custom Header</div>".html_safe }
        "Content"
      end

      expect(page).to have_no_css("h2#modal-title")
      expect(page).to have_css("div", text: "Custom Header")
    end
  end

  describe "slots" do
    describe "header slot" do
      it "renders custom header content" do
        render_inline(described_class.new(id: "modal")) do |modal|
          modal.with_header { "<div class='custom-header'>Custom</div>".html_safe }
          "Body content"
        end

        expect(page).to have_css("div.modal-header div.custom-header", text: "Custom")
      end

      it "renders header section when header slot provided" do
        render_inline(described_class.new(id: "modal")) do |modal|
          modal.with_header { "Header" }
          "Body"
        end

        expect(page).to have_css("div.modal-header")
      end
    end

    describe "body slot" do
      it "renders custom body content when slots used" do
        render_inline(described_class.new(id: "modal")) do |modal|
          modal.with_body { "<p>Body content</p>".html_safe }
        end

        expect(page).to have_css("div.modal-body p", text: "Body content")
      end

      it "renders default content in body when no slots used" do
        render_inline(described_class.new(id: "modal", title: "Test")) do
          "Default content"
        end

        expect(page).to have_css("div.modal-body", text: "Default content")
      end
    end

    describe "footer slot" do
      it "renders footer content" do
        render_inline(described_class.new(id: "modal")) do |modal|
          modal.with_footer { "<button>Save</button>".html_safe }
          "Body"
        end

        expect(page).to have_css("div.modal-footer button", text: "Save")
      end

      it "does not render footer section when footer not provided" do
        render_inline(described_class.new(id: "modal")) { "Content" }

        expect(page).to have_no_css("div.modal-footer")
      end
    end

    describe "close_button slot" do
      it "renders custom close button" do
        render_inline(described_class.new(id: "modal", title: "Test")) do |modal|
          modal.with_close_button { "<button class='custom-close'>X</button>".html_safe }
          "Content"
        end

        expect(page).to have_css("button.custom-close", text: "X")
      end
    end
  end

  describe "HTML attributes" do
    it "merges custom HTML attributes" do
      render_inline(described_class.new(
        id: "modal",
        aria: { describedby: "modal-description" },
        data: { testid: "my-modal" }
      )) { "Content" }

      expect(page).to have_css("dialog[aria-describedby='modal-description']")
      expect(page).to have_css("dialog[data-testid='my-modal']")
    end

    it "merges additional controllers" do
      render_inline(described_class.new(
        id: "modal",
        data: { controller: "custom-controller" }
      )) { "Content" }

      expect(page).to have_css("dialog[data-controller='components--modal custom-controller']")
    end
  end

  describe "CSS classes" do
    it "applies backdrop styling" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("dialog.backdrop\\:bg-slate-900\\/60")
    end

    it "applies modal panel classes" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("div.modal-panel.bg-white.rounded-2xl.shadow-2xl")
    end

    it "applies overflow styling to body" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css("div.modal-body.overflow-y-auto")
    end
  end

  describe ".trigger_attributes class method" do
    it "returns correct data attributes for trigger button" do
      attrs = described_class.trigger_attributes(modal_id: "test-modal")

      expect(attrs[:data][:controller]).to eq("components--modal")
      expect(attrs[:data][:action]).to eq("click->components--modal#triggerOpen")
      expect(attrs[:data][:modal_target]).to eq("test-modal")
    end
  end

  describe ".trigger_data class method" do
    it "returns correct data hash for trigger button" do
      data = described_class.trigger_data(modal_id: "test-modal")

      expect(data[:controller]).to eq("components--modal")
      expect(data[:action]).to eq("click->components--modal#triggerOpen")
      expect(data[:modal_target]).to eq("test-modal")
    end
  end

  describe "keyboard accessibility" do
    it "includes backdrop click action on dialog" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css('[data-action*="click->components--modal#backdropClick"]')
    end

    it "includes close action for close button" do
      render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }

      expect(page).to have_css('[data-action*="click->components--modal#close"]')
    end

    it "close button has aria-label for screen readers" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }

        expect(page).to have_css('[aria-label="Close modal"]')
      end
    end

    it "close button has type=button to prevent form submission" do
      render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }

      expect(page).to have_css('button[type="button"]')
    end

    it "includes panel target for focus management" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css('[data-components--modal-target="panel"]')
    end

    it "title element has correct ID for aria-labelledby" do
      render_inline(described_class.new(id: "my-modal", title: "Test Title")) { "Content" }

      expect(page).to have_css("h2#my-modal-title", text: "Test Title")
    end
  end

  describe "focus management targets" do
    it "includes panel target for initial focus" do
      render_inline(described_class.new(id: "modal", title: "Test")) do |modal|
        modal.with_footer { "<button>Cancel</button><button>Save</button>".html_safe }
        "Body content"
      end

      expect(page).to have_css('[data-components--modal-target="panel"]')
    end

    it "dialog has backdrop click handler" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css('dialog[data-action*="click->components--modal#backdropClick"]')
    end
  end

  describe "ARIA attributes" do
    it "sets aria-modal=true" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      expect(page).to have_css('dialog[aria-modal="true"]')
    end

    it "sets aria-labelledby when title is provided" do
      render_inline(described_class.new(id: "test-modal", title: "My Modal")) { "Content" }

      expect(page).to have_css('dialog[aria-labelledby="test-modal-title"]')
    end

    it "sets aria-labelledby even without explicit title" do
      render_inline(described_class.new(id: "modal")) { "Content" }

      # aria-labelledby should still reference the title area
      expect(page).to have_css('dialog[aria-labelledby="modal-title"]')
    end

    it "sets aria-describedby for body content" do
      render_inline(described_class.new(id: "test-modal", title: "Test")) { "Body content" }

      expect(page).to have_css('dialog[aria-describedby="test-modal-description"]')
      expect(page).to have_css('div#test-modal-description.modal-body', text: "Body content")
    end

    it "hides decorative icon from screen readers" do
      render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }

      # The X-mark icon should have aria-hidden
      expect(page).to have_css('svg[aria-hidden="true"]')
    end
  end

  describe "concerns" do
    it "includes HtmlAttributesRendering concern" do
      expect(described_class.ancestors).to include(HtmlAttributesRendering)
    end

    it "includes I18nHelpers concern" do
      expect(described_class.ancestors).to include(I18nHelpers)
    end
  end

  describe "internationalization" do
    it "uses translated close button aria-label in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }
        expect(page).to have_css('[aria-label="Close modal"]')
      end
    end

    it "uses translated close button aria-label in French" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(id: "modal", title: "Test")) { "Content" }
        expect(page).to have_css('[aria-label="Fermer la fenêtre"]')
      end
    end
  end

  describe "complete example" do
    it "renders modal with all features" do
      render_inline(described_class.new(
        id: "full-modal",
        title: "Complete Modal",
        size: :large,
        dismissible: true,
        open: true,
        close_on_submit: false,
        class: "custom-modal"
      )) do |modal|
        modal.with_header { "<div>Custom Header</div>".html_safe }
        modal.with_body { "<p>Body content</p>".html_safe }
        modal.with_footer { "<button>Submit</button>".html_safe }
      end

      expect(page).to have_css("dialog#full-modal.max-w-2xl")
      expect(page).to have_css("dialog[data-components--modal-open-value='true']")
      expect(page).to have_css("dialog[data-components--modal-dismissible-value='true']")
      expect(page).to have_css("dialog[data-components--modal-close-on-submit-value='false']")
      expect(page).to have_css("div.modal-header div", text: "Custom Header")
      expect(page).to have_css("div.modal-body p", text: "Body content")
      expect(page).to have_css("div.modal-footer button", text: "Submit")
    end
  end
end
