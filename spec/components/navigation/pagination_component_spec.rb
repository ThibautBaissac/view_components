# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::PaginationComponent, type: :component do
  let(:pagy_double) do
    double(
      "Pagy",
      page: 2,
      last: 10,
      previous: 1,
      next: 3,
      from: 21,
      to: 40,
      count: 200
    )
  end

  describe "render?" do
    it "returns true when more than one page" do
      allow(pagy_double).to receive(:last).and_return(5)
      component = described_class.new(pagy: pagy_double)

      expect(component.render?).to be true
    end

    it "returns false when only one page" do
      allow(pagy_double).to receive(:last).and_return(1)
      component = described_class.new(pagy: pagy_double)

      expect(component.render?).to be false
    end
  end

  describe "initialization" do
    it "accepts required pagy parameter" do
      component = described_class.new(pagy: pagy_double)
      expect(component.instance_variable_get(:@pagy)).to eq(pagy_double)
    end

    it "uses default variant" do
      component = described_class.new(pagy: pagy_double)
      expect(component.instance_variable_get(:@variant)).to eq(:default)
    end

    it "uses default size" do
      component = described_class.new(pagy: pagy_double)
      expect(component.instance_variable_get(:@size)).to eq(:medium)
    end

    it "accepts custom variant" do
      component = described_class.new(pagy: pagy_double, variant: :compact)
      expect(component.instance_variable_get(:@variant)).to eq(:compact)
    end

    it "accepts custom size" do
      component = described_class.new(pagy: pagy_double, size: :large)
      expect(component.instance_variable_get(:@size)).to eq(:large)
    end
  end

  describe "validation" do
    it "raises error for invalid variant" do
      expect {
        described_class.new(pagy: pagy_double, variant: :invalid)
      }.to raise_error(ArgumentError, /Invalid variant: invalid/)
    end

    it "raises error for invalid size" do
      expect {
        described_class.new(pagy: pagy_double, size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size: invalid/)
    end

    it "raises error for invalid slots (non-integer)" do
      expect {
        described_class.new(pagy: pagy_double, slots: "invalid")
      }.to raise_error(ArgumentError, /Invalid slots: invalid/)
    end

    it "raises error for invalid slots (non-positive)" do
      expect {
        described_class.new(pagy: pagy_double, slots: 0)
      }.to raise_error(ArgumentError, /Invalid slots: 0/)
    end

    it "accepts valid slots" do
      component = described_class.new(pagy: pagy_double, slots: 5)
      expect(component.instance_variable_get(:@slots)).to eq(5)
    end
  end

  describe "ARIA attributes" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2, :gap, 10 ])
    end

    it "sets aria-label on nav element" do
      render_inline(described_class.new(pagy: pagy_double, aria_label: "Product pages"))

      expect(page).to have_css("nav[aria-label='Product pages']")
    end

    it "sets default aria-label" do
      render_inline(described_class.new(pagy: pagy_double))

      expect(page).to have_css("nav[aria-label='Pagination']")
    end

    it "sets role='navigation'" do
      render_inline(described_class.new(pagy: pagy_double))

      expect(page).to have_css("nav[role='navigation']")
    end
  end

  describe "page info display" do
    context "when show_info is false" do
      it "does not render page info" do
        allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])

        render_inline(described_class.new(pagy: pagy_double, show_info: false))

        expect(page).not_to have_text("21–40 of 200")
      end
    end

    context "when show_info is true" do
      it "renders page info" do
        allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])

        I18n.with_locale(:en) do
          render_inline(described_class.new(pagy: pagy_double, show_info: true))

          expect(page).to have_text("21–40 of 200")
        end
      end

      it "uses I18n translation when available" do
        allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])

        I18n.with_locale(:en) do
          render_inline(described_class.new(pagy: pagy_double, show_info: true))

          # Should display page info with English format
          expect(page).to have_text("21–40 of 200")
        end
      end
    end
  end

  describe "turbo frame integration" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2, 3 ])
      allow(pagy_double).to receive(:previous).and_return(1)
      allow(pagy_double).to receive(:next).and_return(3)
    end

    it "adds turbo-frame attribute when turbo_frame specified" do
      render_inline(described_class.new(pagy: pagy_double, turbo_frame: "items_list"))

      link = page.all("a").first
      expect(link[:"data-turbo-frame"]).to eq("items_list")
    end

    it "sets turbo action" do
      render_inline(described_class.new(pagy: pagy_double, turbo_frame: "items", turbo_action: "replace"))

      link = page.all("a").first
      expect(link[:"data-turbo-action"]).to eq("replace")
    end

    it "does not add turbo attributes when turbo_frame not specified" do
      render_inline(described_class.new(pagy: pagy_double))

      link = page.all("a").first
      expect(link[:"data-turbo-frame"]).to be_nil
    end
  end

  describe "prev/next buttons" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 2 ])
    end

    context "when previous page exists" do
      it "renders enabled previous button" do
        allow(pagy_double).to receive(:previous).and_return(1)

        render_inline(described_class.new(pagy: pagy_double))

        prev_link = page.all("a").first
        expect(prev_link).to be_present
        expect(prev_link[:class]).not_to include("cursor-not-allowed")
      end

      it "sets rel=prev on previous link" do
        allow(pagy_double).to receive(:previous).and_return(1)

        render_inline(described_class.new(pagy: pagy_double))

        prev_link = page.all("a").first
        expect(prev_link[:rel]).to eq("prev")
      end
    end

    context "when previous page does not exist" do
      it "renders disabled previous button" do
        allow(pagy_double).to receive(:previous).and_return(nil)

        render_inline(described_class.new(pagy: pagy_double))

        # Disabled button is rendered as span
        disabled_buttons = page.all("span").select { |el| el[:class]&.include?("cursor-not-allowed") }
        expect(disabled_buttons).not_to be_empty
      end
    end

    context "when next page exists" do
      it "renders enabled next button" do
        allow(pagy_double).to receive(:next).and_return(3)

        render_inline(described_class.new(pagy: pagy_double))

        next_link = page.all("a").last
        expect(next_link).to be_present
        expect(next_link[:class]).not_to include("cursor-not-allowed")
      end

      it "sets rel=next on next link" do
        allow(pagy_double).to receive(:next).and_return(3)

        render_inline(described_class.new(pagy: pagy_double))

        next_link = page.all("a").last
        expect(next_link[:rel]).to eq("next")
      end
    end

    context "when next page does not exist" do
      it "renders disabled next button" do
        allow(pagy_double).to receive(:next).and_return(nil)

        render_inline(described_class.new(pagy: pagy_double))

        disabled_buttons = page.all("span").select { |el| el[:class]&.include?("cursor-not-allowed") }
        expect(disabled_buttons).not_to be_empty
      end
    end
  end

  describe "page numbers rendering" do
    context "with series" do
      before do
        # Current page (2) is returned as a STRING by pagy
        allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, "2", 3, :gap, 8, 9, 10 ])
      end

      it "renders page numbers" do
        render_inline(described_class.new(pagy: pagy_double))

        expect(page).to have_link("1")
        expect(page).to have_link("3")
      end

      it "renders gap as ellipsis" do
        render_inline(described_class.new(pagy: pagy_double))

        # Gap is rendered as span with ellipsis (HTML entity)
        expect(page).to have_css("span", text: "…")
      end

      it "marks current page with active styling" do
        render_inline(described_class.new(pagy: pagy_double))

        # Current page (2) should have active styling and aria-current
        active_page = page.find("span[aria-current='page']")
        expect(active_page.text.strip).to eq("2")
        expect(active_page[:class]).to include("bg-indigo-600")
      end

      it "renders non-current pages as links" do
        render_inline(described_class.new(pagy: pagy_double))

        # Page 1 should be a link (use first since there might be multiple)
        page_1_links = page.all("a", text: "1")
        expect(page_1_links).not_to be_empty
      end
    end
  end

  describe "sizes" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])
    end

    it "applies small size classes" do
      render_inline(described_class.new(pagy: pagy_double, size: :small))

      nav = page.find("nav")
      expect(nav[:class]).to include("gap-1")
    end

    it "applies medium size classes by default" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:class]).to include("gap-1.5")
    end

    it "applies large size classes" do
      render_inline(described_class.new(pagy: pagy_double, size: :large))

      nav = page.find("nav")
      expect(nav[:class]).to include("gap-2")
    end
  end

  describe "variants" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])
    end

    context "default variant" do
      it "renders page numbers and prev/next arrows" do
        render_inline(described_class.new(pagy: pagy_double, variant: :default))

        expect(page).to have_link("1")
        expect(page).to have_link("2")
        # Arrows but no text on prev/next
      end
    end

    context "compact variant" do
      it "renders with shortened labels" do
        render_inline(described_class.new(pagy: pagy_double, variant: :compact))

        # Would show "Prev" and "Next" text
        expect(page).to be_present
      end
    end

    context "minimal variant" do
      it "renders only prev/next with text" do
        render_inline(described_class.new(pagy: pagy_double, variant: :minimal))

        # Would show "Previous" and "Next" text
        expect(page).to be_present
      end
    end
  end

  describe "URL generation" do
    let(:component) { described_class.new(pagy: pagy_double, base_url: "/events") }
    let(:request_double) { double("Request") }
    let(:helpers_double) { double("helpers") }

    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([])
      allow(component).to receive(:helpers).and_return(helpers_double)
      allow(helpers_double).to receive(:request).and_return(request_double)
      allow(request_double).to receive(:path).and_return("/events")
      allow(request_double).to receive(:query_parameters).and_return({})
    end

    it "generates URL with page parameter" do
      url = component.send(:page_url, 3)
      expect(url).to eq("/events?page=3")
    end

    it "preserves existing query parameters" do
      allow(request_double).to receive(:query_parameters).and_return({ "sort" => "name", "filter" => "active" })

      url = component.send(:page_url, 3)
      expect(url).to include("page=3")
      expect(url).to include("sort=name")
      expect(url).to include("filter=active")
    end

    it "uses custom page_key" do
      component = described_class.new(pagy: pagy_double, page_key: "p", base_url: "/events")
      allow(component).to receive(:helpers).and_return(helpers_double)
      allow(helpers_double).to receive(:request).and_return(request_double)
      allow(request_double).to receive(:path).and_return("/events")
      allow(request_double).to receive(:query_parameters).and_return({})

      url = component.send(:page_url, 3)
      expect(url).to eq("/events?p=3")
    end

    it "uses base_url when provided" do
      component = described_class.new(pagy: pagy_double, base_url: "/custom/path")
      # Stub helpers to avoid accessing request
      helpers_stub = double("helpers")
      allow(component).to receive(:helpers).and_return(helpers_stub)
      allow(helpers_stub).to receive(:respond_to?).with(:request).and_return(false)

      url = component.send(:page_url, 2)
      expect(url).to start_with("/custom/path")
    end

    it "falls back to root when request unavailable" do
      component = described_class.new(pagy: pagy_double)
      # Stub helpers to simulate no request available
      helpers_stub = double("helpers")
      allow(component).to receive(:helpers).and_return(helpers_stub)
      allow(helpers_stub).to receive(:respond_to?).with(:request).and_return(false)

      url = component.send(:page_url, 2)
      expect(url).to eq("/?page=2")
    end
  end

  describe "HTML attributes" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])
    end

    it "merges custom CSS classes" do
      render_inline(described_class.new(pagy: pagy_double, class: "custom-pagination"))

      nav = page.find("nav")
      expect(nav[:class]).to include("custom-pagination")
    end

    it "merges custom HTML attributes" do
      render_inline(described_class.new(pagy: pagy_double, id: "my-pagination", data: { testid: "pagination" }))

      nav = page.find("nav")
      expect(nav[:id]).to eq("my-pagination")
      expect(nav[:"data-testid"]).to eq("pagination")
    end
  end

  describe "Stimulus integration" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, 2 ])
    end

    it "adds pagination controller" do
      render_inline(described_class.new(pagy: pagy_double))

      expect(page).to have_css("nav[data-controller='components--pagination']")
    end

    it "sets current page value" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"data-components--pagination-current-page-value"]).to eq("2")
    end

    it "sets total pages value" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"data-components--pagination-total-pages-value"]).to eq("10")
    end

    it "sets turbo frame value when provided" do
      render_inline(described_class.new(pagy: pagy_double, turbo_frame: "items"))

      nav = page.find("nav")
      expect(nav[:"data-components--pagination-turbo-frame-value"]).to eq("items")
    end

    it "does not set turbo frame value when not provided" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"data-components--pagination-turbo-frame-value"]).to be_nil
    end

    it "adds keyboard navigation action" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"data-action"]).to include("keydown->components--pagination#handleKeydown")
    end

    it "adds turbo frame load action" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"data-action"]).to include("turbo:frame-load@window->components--pagination#handleFrameLoad")
    end

    it "adds ARIA live region when turbo frame is present" do
      render_inline(described_class.new(pagy: pagy_double, turbo_frame: "items"))

      nav = page.find("nav")
      expect(nav[:"aria-live"]).to eq("polite")
      expect(nav[:"aria-atomic"]).to eq("false")
    end

    it "does not add ARIA live region when turbo frame is not present" do
      render_inline(described_class.new(pagy: pagy_double))

      nav = page.find("nav")
      expect(nav[:"aria-live"]).to be_nil
      expect(nav[:"aria-atomic"]).to be_nil
    end
  end

  describe "I18n integration" do
    before do
      allow(pagy_double).to receive(:send).with(:series, slots: 7).and_return([ 1, "2", 3 ])
    end

    it "uses component I18n scope" do
      component = described_class.new(pagy: pagy_double)
      expect(component.send(:component_i18n_scope)).to eq("components.navigation.pagination")
    end

    it "provides localized button text in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(pagy: pagy_double, variant: :minimal))

        # Should use English translated text
        expect(page).to have_text("Previous")
        expect(page).to have_text("Next")
      end
    end

    it "provides localized button text in French" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(pagy: pagy_double, variant: :minimal))

        # Should use French translated text
        expect(page).to have_text("Précédent")
        expect(page).to have_text("Suivant")
      end
    end

    it "provides localized page info in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(pagy: pagy_double, show_info: true))

        # Should display page info with English format
        expect(page).to have_text(/\d+–\d+ of \d+/)
      end
    end

    it "provides localized page info in French" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(pagy: pagy_double, show_info: true))

        # Should display page info with French format
        expect(page).to have_text(/\d+–\d+ sur \d+/)
      end
    end
  end

  describe "complete example" do
    before do
      # Current page (2) is returned as a STRING by pagy
      allow(pagy_double).to receive(:send).with(:series, slots: 5).and_return([ 1, "2", :gap, 10 ])
      allow(pagy_double).to receive(:previous).and_return(1)
      allow(pagy_double).to receive(:next).and_return(3)
    end

    it "renders complete pagination" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          pagy: pagy_double,
          variant: :default,
          size: :medium,
          slots: 5,
          show_info: true,
          turbo_frame: "items",
          aria_label: "Items pagination"
        ))

        expect(page).to have_css("nav[role='navigation'][aria-label='Items pagination']")
        expect(page).to have_text("21–40 of 200")
        expect(page).to have_link("1")
        # Current page with active styling and aria-current
        expect(page).to have_css("span[aria-current='page']", text: "2")
        expect(page).to have_css("span", text: "…") # Gap (ellipsis entity)
        expect(page).to have_link("10")

        # Check turbo integration
        links = page.all("a[href]")
        expect(links.first[:"data-turbo-frame"]).to eq("items")
      end
    end
  end
end
