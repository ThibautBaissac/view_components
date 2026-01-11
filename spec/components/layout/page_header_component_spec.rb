# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::PageHeaderComponent, type: :component do
  describe "basic rendering" do
    it "renders title only" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("h1", text: "Events")
    end

    it "uses semantic header element" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("header.mb-6")
    end

    it "wraps title in title container" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("div.flex.items-center.gap-3.mb-2 h1")
    end
  end

  describe "description rendering" do
    it "renders description when provided" do
      render_inline(described_class.new(
        title: "Events",
        description: "Manage your events and weddings"
      ))

      expect(page).to have_css("p.text-slate-600", text: "Manage your events and weddings")
      expect(page).to have_css("p.mt-1")
    end

    it "does not render description when not provided" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_no_css("p.text-slate-600")
    end
  end

  describe "badge slot" do
    it "renders badge in title container" do
      render_inline(described_class.new(title: "Event Details")) do |header|
        header.with_badge do
          "<span class='badge-confirmed'>Confirmed</span>".html_safe
        end
      end

      expect(page).to have_css("div.flex.items-center.gap-3 span.badge-confirmed", text: "Confirmed")
    end

    it "positions badge next to title" do
      render_inline(described_class.new(title: "John & Jane")) do |header|
        header.with_badge do
          "<span class='badge'>Badge</span>".html_safe
        end
      end

      # Both title and badge in same container
      title_container = page.find("div.flex.items-center.gap-3")
      expect(title_container).to have_css("h1", text: "John & Jane")
      expect(title_container).to have_css("span.badge", text: "Badge")
    end
  end

  describe "back link" do
    it "renders back link with nav landmark when back_url provided" do
      render_inline(described_class.new(
        title: "Event Details",
        back_url: "/events"
      ))

      # Should use nav landmark
      expect(page).to have_css("nav.flex.gap-2.mt-4")
    end

    it "uses custom back_text" do
      render_inline(described_class.new(
        title: "Event Details",
        back_url: "/events",
        back_text: "← Retour aux événements"
      ))

      expect(page).to have_text("← Retour aux événements")
    end

    it "uses I18n default back_text in French" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_text("← Retour à la liste")
      end
    end

    it "uses I18n default back_text in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_text("← Back to list")
      end
    end

    it "does not render back link when back_url not provided" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_no_css("nav.flex.gap-2.mt-4")
    end
  end

  describe "action slot" do
    it "renders action button" do
      render_inline(described_class.new(title: "Events")) do |header|
        header.with_action do
          "<a href='/events/new' class='btn-primary'>New Event</a>".html_safe
        end
      end

      expect(page).to have_css("a.btn-primary", text: "New Event")
    end

    it "renders action in responsive flex container with title when no back link" do
      render_inline(described_class.new(title: "Events")) do |header|
        header.with_action do
          "<button>Action</button>".html_safe
        end
      end

      # Action should be in responsive container
      expect(page).to have_css("div.flex.flex-col")
      expect(page).to have_css("button", text: "Action")
    end

    it "does not show action container when both action and back_link present" do
      render_inline(described_class.new(
        title: "Event Details",
        back_url: "/events"
      )) do |header|
        header.with_action do
          "<button>Edit</button>".html_safe
        end
      end

      # When back_link is present, action is not shown in the responsive container
      expect(page).to have_no_css("div.flex-col.md\\:flex-row")
    end
  end

  describe "layout variations" do
    context "with action but no back link" do
      it "uses responsive flex layout" do
        render_inline(described_class.new(title: "Events")) do |header|
          header.with_action { "<button>New</button>".html_safe }
        end

        expect(page).to have_css("div.flex.flex-col")
      end
    end

    context "with back link but no action" do
      it "uses standard layout with nav below" do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_no_css("div.flex-col.md\\:flex-row")
        expect(page).to have_css("nav.flex.gap-2.mt-4")
      end
    end

    context "with both action and back link" do
      it "prioritizes back link layout" do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        )) do |header|
          header.with_action { "<button>Edit</button>".html_safe }
        end

        # Back link layout is used
        expect(page).to have_css("nav.flex.gap-2.mt-4")
        # Action container is not shown
        expect(page).to have_no_css("div.flex-col.md\\:flex-row")
      end
    end
  end

  describe "HTML attributes" do
    it "merges custom HTML attributes" do
      render_inline(described_class.new(
        title: "Events",
        id: "page-header",
        data: { testid: "header" }
      ))

      expect(page).to have_css("header[id='page-header']")
      expect(page).to have_css("header[data-testid='header']")
    end

    it "merges custom CSS classes" do
      render_inline(described_class.new(
        title: "Events",
        class: "custom-header border-b"
      ))

      expect(page).to have_css("header.mb-6.custom-header.border-b")
    end
  end

  describe "complete example" do
    it "renders with title, badge, description, and action" do
      render_inline(described_class.new(
        title: "John & Jane Smith",
        description: "Wedding on June 15, 2024",
        class: "custom-class"
      )) do |header|
        header.with_badge do
          "<span class='badge-success'>Confirmed</span>".html_safe
        end
        header.with_action do
          "<a href='/events/1/edit'>Edit</a>".html_safe
        end
      end

      expect(page).to have_css("header.mb-6.custom-class")
      expect(page).to have_css("h1", text: "John & Jane Smith")
      expect(page).to have_css("span.badge-success", text: "Confirmed")
      expect(page).to have_css("p.text-slate-600", text: "Wedding on June 15, 2024")
      expect(page).to have_css("a", text: "Edit")
    end

    it "renders with back link and badge" do
      render_inline(described_class.new(
        title: "Event Details",
        back_url: "/events",
        back_text: "← Back to events"
      )) do |header|
        header.with_badge do
          "<span class='badge'>Pending</span>".html_safe
        end
      end

      expect(page).to have_css("h1", text: "Event Details")
      expect(page).to have_css("span.badge", text: "Pending")
      expect(page).to have_text("← Back to events")
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

  describe "accessibility" do
    it "uses semantic header element" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("header")
    end

    it "has proper heading hierarchy with h1" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("h1", text: "Events")
    end

    it "includes nav landmark for back link" do
      render_inline(described_class.new(
        title: "Event Details",
        back_url: "/events"
      ))

      expect(page).to have_css("nav[aria-label]")
    end

    it "links title to description with aria-describedby" do
      render_inline(described_class.new(
        title: "Event Details",
        description: "This is the description"
      ))

      h1 = page.find("h1")
      described_by_id = h1["aria-describedby"]
      expect(described_by_id).to be_present
      expect(page).to have_css("p##{described_by_id}", text: "This is the description")
    end

    it "adds role=status to badge container" do
      render_inline(described_class.new(title: "Event")) do |header|
        header.with_badge do
          "<span>Badge</span>".html_safe
        end
      end

      expect(page).to have_css("div[role='status']")
    end

    it "adds role=region to action container" do
      render_inline(described_class.new(title: "Events")) do |header|
        header.with_action do
          "<button>Action</button>".html_safe
        end
      end

      expect(page).to have_css("div[role='region'][aria-label]")
    end

    it "nav has proper aria-label for breadcrumb" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_css("nav[aria-label=\"Fil d'ariane\"]")
      end
    end
  end

  describe "internationalization" do
    it "uses translated back link text in French" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_text("← Retour à la liste")
      end
    end

    it "uses translated back link text in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events"
        ))

        expect(page).to have_text("← Back to list")
      end
    end

    it "allows custom back_text to override translation" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          title: "Event Details",
          back_url: "/events",
          back_text: "Custom Back Text"
        ))

        expect(page).to have_text("Custom Back Text")
        expect(page).to have_no_text("← Back to list")
      end
    end
  end

  describe "responsive design" do
    it "includes responsive text size classes for title" do
      render_inline(described_class.new(title: "Events"))

      expect(page).to have_css("h1.text-2xl.md\\:text-3xl")
    end

    it "includes responsive text size classes for description" do
      render_inline(described_class.new(
        title: "Events",
        description: "Test description"
      ))

      expect(page).to have_css("p.text-sm.md\\:text-base")
    end

    it "uses responsive flex layout for action container" do
      render_inline(described_class.new(title: "Events")) do |header|
        header.with_action do
          "<button>Action</button>".html_safe
        end
      end

      expect(page).to have_css("div.flex-col.md\\:flex-row")
    end
  end
end
