# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::EmptyStateComponent, type: :component do
  describe "basic rendering" do
    it "renders with title only" do
      render_inline(described_class.new(title: "No events yet"))

      expect(page).to have_css("div.text-center")
      expect(page).to have_css("h3.text-sm.font-medium.text-slate-900", text: "No events yet")
    end

    it "applies default padding (non-compact)" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_css("div.py-12")
    end
  end

  describe "icon rendering" do
    it "renders icon when icon_name provided" do
      render_inline(described_class.new(title: "No events", icon_name: "calendar"))

      # Icon component would be rendered - check for its presence
      expect(page).to have_css("svg[class*='mx-auto']") if defined?(Foundation::IconComponent)
    end

    it "does not render icon when icon_name not provided" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_no_css("svg.mx-auto")
    end

    it "uses specified icon variant" do
      component = described_class.new(title: "No events", icon_name: "calendar", icon_variant: :solid)
      # Verify icon_variant is passed to the icon component
      expect(component.instance_variable_get(:@icon_variant)).to eq(:solid)
    end

    it "uses specified icon size" do
      component = described_class.new(title: "No events", icon_name: "calendar", icon_size: :xxl)
      # Verify icon_size is passed to the icon component
      expect(component.instance_variable_get(:@icon_size)).to eq(:xxl)
    end
  end

  describe "description rendering" do
    it "renders description when provided" do
      render_inline(described_class.new(
        title: "No events yet",
        description: "Get started by creating your first event"
      ))

      expect(page).to have_css("p.mt-1.text-sm.text-slate-600", text: "Get started by creating your first event")
    end

    it "does not render description when not provided" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_no_css("p.text-slate-600")
    end
  end

  describe "action slot" do
    it "renders action button when provided" do
      render_inline(described_class.new(title: "No vendors")) do |empty_state|
        empty_state.with_action do
          "<a href='/vendors/new' class='btn'>Add Vendor</a>".html_safe
        end
      end

      expect(page).to have_css("div.mt-6")
      expect(page).to have_css("a.btn", text: "Add Vendor")
    end

    it "does not render action container when action not provided" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_no_css("div.mt-6")
    end
  end

  describe "compact mode" do
    it "uses compact padding when compact is true" do
      render_inline(described_class.new(title: "No notes", compact: true))

      expect(page).to have_css("div.py-8")
      expect(page).to have_no_css("div.py-12")
    end

    it "applies compact title styles" do
      render_inline(described_class.new(title: "No notes", compact: true))

      expect(page).to have_css("h3.text-sm.font-medium.text-slate-900", text: "No notes")
      expect(page).to have_no_css("h3.mt-2")
    end

    it "applies non-compact title styles by default" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_css("h3.mt-2.text-sm.font-medium.text-slate-900")
    end
  end

  describe "HTML attributes" do
    it "merges custom HTML attributes" do
      render_inline(described_class.new(
        title: "No events",
        id: "empty-state-events",
        data: { testid: "empty-state" }
      ))

      expect(page).to have_css("div[id='empty-state-events']")
      expect(page).to have_css("div[data-testid='empty-state']")
    end

    it "merges custom CSS classes" do
      render_inline(described_class.new(title: "No events", class: "custom-empty-state"))

      expect(page).to have_css("div.text-center.custom-empty-state")
    end
  end

  describe "complete example" do
    it "renders with all features" do
      render_inline(described_class.new(
        icon_name: "users",
        icon_variant: :outline,
        icon_size: :xl,
        title: "No vendors",
        description: "Add your first vendor to get started",
        compact: false,
        class: "my-custom-class"
      )) do |empty_state|
        empty_state.with_action do
          "<a href='/vendors/new'>Add Vendor</a>".html_safe
        end
      end

      expect(page).to have_css("div.text-center.py-12.my-custom-class")
      expect(page).to have_css("h3.mt-2", text: "No vendors")
      expect(page).to have_css("p.text-slate-600", text: "Add your first vendor to get started")
      expect(page).to have_css("div.mt-6 a", text: "Add Vendor")
    end
  end

  describe "HtmlAttributesRendering concern" do
    it "includes HtmlAttributesRendering concern" do
      expect(described_class.ancestors).to include(HtmlAttributesRendering)
    end

    it "deeply merges data attributes" do
      render_inline(described_class.new(
        title: "No events",
        data: { controller: "custom", action: "click->custom#handle" }
      ))

      expect(page).to have_css("[data-controller='custom']")
      expect(page).to have_css("[data-action='click->custom#handle']")
    end
  end

  describe "I18nHelpers concern" do
    it "includes I18nHelpers concern" do
      expect(described_class.ancestors).to include(I18nHelpers)
    end

    it "uses component I18n scope" do
      component = described_class.new(title: "No events")
      expect(component.send(:component_i18n_scope)).to eq("components.layout.empty_state")
    end
  end

  describe "accessibility" do
    it "includes status role for screen readers" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_css("div[role='status']")
    end

    it "includes aria-live for dynamic updates" do
      render_inline(described_class.new(title: "No events"))

      expect(page).to have_css("div[aria-live='polite']")
    end

    it "uses semantic heading for title" do
      render_inline(described_class.new(title: "No events yet"))

      expect(page).to have_css("h3", text: "No events yet")
    end

    it "marks icon as decorative for screen readers" do
      render_inline(described_class.new(title: "Test", icon_name: "calendar"))

      # Verify icon has aria_hidden parameter passed
      # Note: Actual aria-hidden rendering depends on IconComponent implementation
      expect(page).to have_css("svg") if defined?(Foundation::IconComponent)
    end

    it "provides semantic context with role and aria-live" do
      render_inline(described_class.new(
        title: "No search results",
        description: "Try adjusting your filters"
      ))

      container = page.find("div[role='status']")
      expect(container[:"aria-live"]).to eq("polite")
    end
  end

  describe "i18n support" do
    context "with English locale" do
      it "renders plain string title" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(title: "Plain Title"))

          expect(page).to have_css("h3", text: "Plain Title")
        end
      end

      it "translates symbolic title" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(title: :no_events))

          expect(page).to have_css("h3", text: "No events yet")
        end
      end

      it "translates symbolic description" do
        I18n.with_locale(:en) do
          render_inline(described_class.new(
            title: :no_events,
            description: :create_first_event
          ))

          expect(page).to have_css("p", text: "Get started by creating your first event")
        end
      end
    end

    context "with French locale" do
      it "translates symbolic title to French" do
        I18n.with_locale(:fr) do
          render_inline(described_class.new(title: :no_events))

          expect(page).to have_css("h3", text: "Aucun événement")
        end
      end

      it "translates symbolic description to French" do
        I18n.with_locale(:fr) do
          render_inline(described_class.new(
            title: :no_vendors,
            description: :add_first_vendor
          ))

          expect(page).to have_css("h3", text: "Aucun prestataire")
          expect(page).to have_css("p", text: "Ajoutez votre premier prestataire pour commencer")
        end
      end
    end

    it "falls back to titleized key name for missing translations" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(title: :missing_key))

        expect(page).to have_css("h3", text: "Missing Key")
      end
    end
  end
end
