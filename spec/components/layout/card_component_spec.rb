# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::CardComponent, type: :component do
  describe "basic rendering" do
    it "renders a card with content" do
      render_inline(described_class.new) { "Card content" }

      expect(page).to have_css("article.bg-white.rounded-2xl.border.border-slate-200\\/70", text: "Card content")
    end

    it "applies default large padding to content" do
      render_inline(described_class.new) { "Content" }

      expect(page).to have_css("div.p-8", text: "Content")
    end
  end

  describe "padding options" do
    it "renders with no padding" do
      render_inline(described_class.new(padding: :none)) { "Content" }

      expect(page).to have_css("div:not([class*='p-'])", text: "Content")
    end

    it "renders with small padding" do
      render_inline(described_class.new(padding: :small)) { "Content" }

      expect(page).to have_css("div.p-4", text: "Content")
    end

    it "renders with medium padding" do
      render_inline(described_class.new(padding: :medium)) { "Content" }

      expect(page).to have_css("div.p-6", text: "Content")
    end

    it "renders with large padding (default)" do
      render_inline(described_class.new(padding: :large)) { "Content" }

      expect(page).to have_css("div.p-8", text: "Content")
    end
  end

  describe "sticky positioning" do
    it "applies sticky classes when sticky is true" do
      render_inline(described_class.new(sticky: true)) { "Content" }

      expect(page).to have_css("article.sticky.top-6")
    end

    it "does not apply sticky classes by default" do
      render_inline(described_class.new) { "Content" }

      expect(page).to have_no_css("article.sticky")
    end
  end

  describe "header slot" do
    it "renders header with title only" do
      render_inline(described_class.new) do |card|
        card.with_header(title: "Card Title")
        "Card body"
      end

      expect(page).to have_css("h2.text-lg.font-semibold.text-slate-900", text: "Card Title")
      expect(page).to have_css("div.px-8.pt-8.pb-0")
    end

    it "renders header with title and action content" do
      render_inline(described_class.new) do |card|
        card.with_header(title: "Vendors") do
          "<button>Add Vendor</button>".html_safe
        end
        "Card body"
      end

      expect(page).to have_css("h2", text: "Vendors")
      expect(page).to have_css("button", text: "Add Vendor")
    end

    it "renders header with only block content (no title)" do
      render_inline(described_class.new) do |card|
        card.with_header do
          "<div>Custom header content</div>".html_safe
        end
        "Card body"
      end

      expect(page).to have_css("div.px-8.pt-8")
      # h2 should NOT be rendered when title is nil (fixed bug)
      expect(page).to have_no_css("h2")
      expect(page).to have_css("div", text: "Custom header content")
    end

    it "applies border to title when title is present" do
      render_inline(described_class.new) do |card|
        card.with_header(title: "Title")
        "Body"
      end

      expect(page).to have_css("h2.border-b.border-slate-200", text: "Title")
    end
  end

  describe "footer slot" do
    it "renders footer content" do
      render_inline(described_class.new) do |card|
        card.with_footer { "Total: €1,234" }
        "Card body"
      end

      expect(page).to have_css("div.px-8.pb-8.pt-4.border-t.border-slate-200", text: "Total: €1,234")
    end

    it "does not render footer section when footer not provided" do
      render_inline(described_class.new) { "Content" }

      expect(page).to have_no_css("div.border-t")
    end
  end

  describe "HTML attributes" do
    it "merges custom HTML attributes" do
      render_inline(described_class.new(id: "custom-card", data: { controller: "my-controller" })) { "Content" }

      expect(page).to have_css("article[id='custom-card']")
      expect(page).to have_css("article[data-controller='my-controller']")
    end

    it "merges custom CSS classes" do
      render_inline(described_class.new(class: "shadow-xl my-4")) { "Content" }

      expect(page).to have_css("article.bg-white.shadow-xl.my-4")
    end
  end

  describe "complete example" do
    it "renders card with all features" do
      render_inline(described_class.new(padding: :medium, sticky: true, class: "custom-class")) do |card|
        card.with_header(title: "Summary") do
          "<button>Action</button>".html_safe
        end
        card.with_footer { "Footer content" }
        "Main content"
      end

      expect(page).to have_css("article.sticky.top-6.custom-class")
      expect(page).to have_css("h2", text: "Summary")
      expect(page).to have_css("button", text: "Action")
      expect(page).to have_css("div.p-6", text: "Main content")
      expect(page).to have_css("div.border-t", text: "Footer content")
    end
  end

  describe "parameter validation" do
    it "raises error for invalid padding" do
      expect {
        described_class.new(padding: :invalid)
      }.to raise_error(ArgumentError, /Invalid padding: invalid/)
    end

    it "accepts valid padding values" do
      described_class::PADDINGS.each do |valid_padding|
        expect {
          described_class.new(padding: valid_padding)
        }.not_to raise_error
      end
    end
  end

  describe "HtmlAttributesRendering concern" do
    it "includes HtmlAttributesRendering concern" do
      expect(described_class.ancestors).to include(HtmlAttributesRendering)
    end

    it "deeply merges data attributes" do
      render_inline(described_class.new(
        data: { controller: "custom", action: "click->custom#handle" }
      )) { "Content" }

      expect(page).to have_css("[data-controller='custom']")
      expect(page).to have_css("[data-action='click->custom#handle']")
    end
  end

  describe "accessibility" do
    it "uses semantic HTML article element" do
      render_inline(described_class.new) { "Content" }

      expect(page).to have_css("article.bg-white.rounded-2xl")
    end

    it "header has proper heading hierarchy" do
      render_inline(described_class.new) do |card|
        card.with_header(title: "Test Title")
        "Content"
      end

      expect(page).to have_css("h2", text: "Test Title")
    end

    it "does not render empty heading when header has no title" do
      render_inline(described_class.new) do |card|
        card.with_header { "Custom content" }
        "Body"
      end

      expect(page).to have_no_css("h2:empty")
      expect(page).to have_no_css("h2")
    end

    it "header respects padding parameter" do
      render_inline(described_class.new(padding: :small)) do |card|
        card.with_header(title: "Title")
        "Body"
      end

      expect(page).to have_css("div.px-4.pt-4")
    end
  end

  describe "footer padding responsiveness" do
    it "footer respects none padding" do
      render_inline(described_class.new(padding: :none)) do |card|
        card.with_footer { "Footer" }
        "Body"
      end

      # Should have minimal/no padding classes
      footer = page.find("div.border-t")
      expect(footer[:class]).to match(/px-0|pb-0|pt-0/)
    end

    it "footer respects small padding" do
      render_inline(described_class.new(padding: :small)) do |card|
        card.with_footer { "Footer" }
        "Body"
      end

      expect(page).to have_css("div.px-4.pb-4.pt-2", text: "Footer")
    end

    it "footer respects medium padding" do
      render_inline(described_class.new(padding: :medium)) do |card|
        card.with_footer { "Footer" }
        "Body"
      end

      expect(page).to have_css("div.px-6.pb-6.pt-3", text: "Footer")
    end

    it "footer respects large padding" do
      render_inline(described_class.new(padding: :large)) do |card|
        card.with_footer { "Footer" }
        "Body"
      end

      expect(page).to have_css("div.px-8.pb-8.pt-4", text: "Footer")
    end
  end
end
