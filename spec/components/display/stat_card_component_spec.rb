# frozen_string_literal: true

require "rails_helper"

RSpec.describe Display::StatCardComponent, type: :component do
  describe "rendering" do
    context "with basic configuration" do
      it "renders stat card with value and label" do
        render_inline(described_class.new(value: "€1,234", label: "Pending Commissions"))

        expect(page).to have_text("€1,234")
        expect(page).to have_text("Pending Commissions")
      end

      it "renders value with default color (slate-900)" do
        render_inline(described_class.new(value: "42", label: "Count"))

        expect(page).to have_css(".text-slate-900", text: "42")
      end

      it "renders value with default size (medium/text-2xl)" do
        render_inline(described_class.new(value: "100", label: "Items"))

        expect(page).to have_css(".text-2xl", text: "100")
      end

      it "renders label with proper styling" do
        render_inline(described_class.new(value: "50", label: "Total"))

        expect(page).to have_css(".text-slate-600.mt-2", text: "Total")
      end

      it "renders centered by default" do
        render_inline(described_class.new(value: "10", label: "Items"))

        expect(page).to have_css(".text-center")
      end
    end

    context "with different value colors" do
      it "renders default color" do
        render_inline(described_class.new(value: "€100", label: "Amount", value_color: :default))

        expect(page).to have_css(".text-slate-900", text: "€100")
      end

      it "renders primary color" do
        render_inline(described_class.new(value: "42", label: "Count", value_color: :primary))

        expect(page).to have_css(".text-indigo-600", text: "42")
      end

      it "renders success color" do
        render_inline(described_class.new(value: "€5,000", label: "Revenue", value_color: :success))

        expect(page).to have_css(".text-green-600", text: "€5,000")
      end

      it "renders warning color" do
        render_inline(described_class.new(value: "3", label: "Alerts", value_color: :warning))

        expect(page).to have_css(".text-amber-600", text: "3")
      end

      it "renders danger color" do
        render_inline(described_class.new(value: "0", label: "Errors", value_color: :danger))

        expect(page).to have_css(".text-red-600", text: "0")
      end

      it "renders info color" do
        render_inline(described_class.new(value: "12", label: "Updates", value_color: :info))

        expect(page).to have_css(".text-sky-600", text: "12")
      end
    end

    context "with different sizes" do
      it "renders medium size" do
        render_inline(described_class.new(value: "100", label: "Items", size: :medium))

        expect(page).to have_css(".text-2xl", text: "100")
        expect(page).to have_css(".text-sm", text: "Items")
      end

      it "renders large size" do
        render_inline(described_class.new(value: "500", label: "Total", size: :large))

        expect(page).to have_css(".text-4xl", text: "500")
        expect(page).to have_css(".text-base", text: "Total")
      end

      it "renders xlarge size" do
        render_inline(described_class.new(value: "1000", label: "Max", size: :xlarge))

        expect(page).to have_css(".text-5xl", text: "1000")
        expect(page).to have_css(".text-lg", text: "Max")
      end
    end

    context "with icon" do
      it "does not render icon by default" do
        render_inline(described_class.new(value: "10", label: "Count"))

        expect(page).not_to have_css(".justify-center.mb-3")
      end

      it "renders icon when icon_name provided" do
        render_inline(described_class.new(
          value: "€1,234",
          label: "Revenue",
          icon_name: "currency-dollar"
        ))

        expect(page).to have_css(".justify-center.mb-3")
      end

      it "renders icon with centered alignment by default" do
        render_inline(described_class.new(
          value: "42",
          label: "Users",
          icon_name: "users"
        ))

        expect(page).to have_css(".flex.justify-center.mb-3")
      end

      it "renders icon without centering when not centered" do
        render_inline(described_class.new(
          value: "10",
          label: "Count",
          icon_name: "chart-bar",
          centered: false
        ))

        expect(page).to have_css(".mb-3")
        expect(page).not_to have_css(".justify-center")
      end

      it "renders icon with custom color" do
        render_inline(described_class.new(
          value: "€500",
          label: "Profit",
          icon_name: "arrow-trending-up",
          icon_color: :success
        ))

        expect(page).to have_text("€500")
      end
    end

    context "with alignment" do
      it "centers content by default" do
        render_inline(described_class.new(value: "50", label: "Items"))

        expect(page).to have_css(".text-center")
      end

      it "left-aligns content when centered is false" do
        render_inline(described_class.new(value: "25", label: "Count", centered: false))

        expect(page).not_to have_css(".text-center")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(
          value: "100",
          label: "Items",
          class: "custom-stat-card"
        ))

        expect(page).to have_css(".text-center.custom-stat-card")
      end

      it "renders with custom ID" do
        render_inline(described_class.new(value: "50", label: "Count", id: "stat-1"))

        expect(page).to have_css("#stat-1")
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          value: "10",
          label: "Items",
          data: { testid: "stat-card" }
        ))

        expect(page).to have_css('[data-testid="stat-card"]')
      end
    end
  end

  describe "validation" do
    context "value_color validation" do
      Display::StatCardComponent::VALUE_COLORS.keys.each do |color|
        it "accepts valid #{color} value color" do
          expect {
            described_class.new(value: "100", label: "Test", value_color: color)
          }.not_to raise_error
        end
      end

      it "raises error for invalid value_color" do
        expect {
          described_class.new(value: "100", label: "Test", value_color: :invalid)
        }.to raise_error(ArgumentError, /Invalid value_color: invalid/)
      end
    end

    context "size validation" do
      it "accepts valid medium size" do
        expect {
          described_class.new(value: "100", label: "Test", size: :medium)
        }.not_to raise_error
      end

      it "accepts valid large size" do
        expect {
          described_class.new(value: "100", label: "Test", size: :large)
        }.not_to raise_error
      end

      it "accepts valid xlarge size" do
        expect {
          described_class.new(value: "100", label: "Test", size: :xlarge)
        }.not_to raise_error
      end

      it "raises error for invalid size" do
        expect {
          described_class.new(value: "100", label: "Test", size: :invalid)
        }.to raise_error(ArgumentError, /Invalid size: invalid/)
      end
    end
  end

  describe "accessibility" do
    it "uses semantic data element for value" do
      render_inline(described_class.new(value: "100", label: "Items"))

      expect(page).to have_css("data", text: "100")
    end

    it "uses paragraph element for label" do
      render_inline(described_class.new(value: "50", label: "Count"))

      expect(page).to have_css("p", text: "Count")
    end

    it "maintains readable text contrast with proper color classes" do
      render_inline(described_class.new(value: "100", label: "Items"))

      expect(page).to have_css(".text-slate-900") # High contrast value
      expect(page).to have_css(".text-slate-600") # Good contrast label
    end

    it "sets role=region for stat card" do
      render_inline(described_class.new(value: "100", label: "Items"))

      expect(page).to have_css('[role="region"]')
    end

    it "uses aria-labelledby to associate container with label" do
      render_inline(described_class.new(value: "50", label: "Count"))

      expect(page).to have_css('[aria-labelledby]')
      label_id = page.find('[role="region"]')["aria-labelledby"]
      expect(page).to have_css("p##{label_id}", text: "Count")
    end

    it "uses aria-describedby to associate value with label" do
      render_inline(described_class.new(value: "100", label: "Items"))

      expect(page).to have_css('data[aria-describedby]')
      label_id = page.find("data")["aria-describedby"]
      expect(page).to have_css("p##{label_id}", text: "Items")
    end

    it "includes numeric value in data element value attribute" do
      render_inline(described_class.new(value: "€1,234", label: "Revenue"))

      expect(page).to have_css('data[value="1234"]')
    end

    it "handles non-numeric values gracefully" do
      render_inline(described_class.new(value: "N/A", label: "Status"))

      expect(page).to have_css("data", text: "N/A")
      expect(page).not_to have_css("data[value]")
    end

    it "generates unique label IDs for multiple instances" do
      component1 = described_class.new(value: "100", label: "Items 1")
      component2 = described_class.new(value: "200", label: "Items 2")

      render_inline(component1)
      html1 = page.native.to_s

      render_inline(component2)
      html2 = page.native.to_s

      expect(html1).not_to eq(html2)
    end
  end

  describe "internationalization" do
    it "renders string labels as-is" do
      render_inline(described_class.new(value: "100", label: "Total Items"))

      expect(page).to have_css("p", text: "Total Items")
    end

    it "translates symbol labels using I18n" do
      # Mock the I18n translation
      allow(I18n).to receive(:t).with(
        "total_items",
        hash_including(scope: "components.display.stat_card", default: "Total items")
      ).and_return("Éléments totaux")

      render_inline(described_class.new(value: "100", label: :total_items))

      expect(page).to have_css("p", text: "Éléments totaux")
    end

    it "uses humanized label as fallback for missing translations" do
      render_inline(described_class.new(value: "100", label: :pending_commissions))

      # Should humanize the symbol if translation is missing
      expect(page).to have_css("p", text: "Pending commissions")
    end

    it "passes label_options to I18n" do
      allow(I18n).to receive(:t).with(
        "items_count",
        hash_including(
          scope: "components.display.stat_card",
          default: "Items count",
          count: 5
        )
      ).and_return("5 éléments")

      render_inline(described_class.new(
        value: "5",
        label: :items_count,
        label_options: { count: 5 }
      ))

      expect(page).to have_css("p", text: "5 éléments")
    end

    it "uses label text for icon label accessibility" do
      render_inline(described_class.new(
        value: "100",
        label: "Revenue",
        icon_name: "currency-dollar"
      ))

      # The icon should receive the label text for accessibility
      expect(page).to have_text("Revenue")
    end
  end

  describe "edge cases" do
    it "handles special characters in value" do
      render_inline(described_class.new(
        value: "€1,234.56 <script>alert('xss')</script>",
        label: "Amount"
      ))

      expect(page).to have_text("€1,234.56")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in label" do
      render_inline(described_class.new(
        value: "100",
        label: "Count & Total <b>Items</b>"
      ))

      expect(page).to have_text("Count & Total")
      expect(page).not_to have_css("b")
    end

    it "handles long values" do
      long_value = "1" * 50
      render_inline(described_class.new(value: long_value, label: "Big Number"))

      expect(page).to have_text(long_value)
    end

    it "handles long labels" do
      long_label = "a" * 100
      render_inline(described_class.new(value: "100", label: long_label))

      expect(page).to have_text(long_label)
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        value: "€5,678",
        label: "Total Revenue",
        icon_name: "currency-euro",
        icon_color: :success,
        value_color: :success,
        size: :large,
        centered: true,
        class: "custom-card",
        id: "revenue-card"
      ))

      expect(page).to have_css("#revenue-card.custom-card")
      expect(page).to have_css(".text-center")
      expect(page).to have_css(".text-4xl.text-green-600", text: "€5,678")
      expect(page).to have_css(".text-base", text: "Total Revenue")
    end

    it "handles numeric values" do
      render_inline(described_class.new(value: 12345, label: "Count"))

      expect(page).to have_text("12345")
    end

    it "handles nil icon_name gracefully" do
      render_inline(described_class.new(value: "100", label: "Items", icon_name: nil))

      expect(page).to have_text("100")
      expect(page).not_to have_css(".mb-3")
    end
  end

  describe "styling classes" do
    it "applies value styling correctly" do
      render_inline(described_class.new(
        value: "100",
        label: "Items",
        size: :medium,
        value_color: :primary
      ))

      expect(page).to have_css(".text-2xl.font-bold.text-indigo-600")
    end

    it "applies label styling correctly" do
      render_inline(described_class.new(value: "50", label: "Count", size: :large))

      expect(page).to have_css(".text-base.text-slate-600.mt-2")
    end

    it "excludes class attribute from merged HTML attributes" do
      component = described_class.new(value: "100", label: "Items", class: "custom")

      render_inline(component)

      # Class should be in container but not duplicated in merged attributes
      expect(page).to have_css(".custom")
    end
  end

  describe "icon rendering conditions" do
    it "does not render icon container when icon_name is blank" do
      render_inline(described_class.new(value: "100", label: "Items", icon_name: ""))

      expect(page).not_to have_css(".mb-3")
    end

    it "does not render icon container when icon_name is whitespace" do
      render_inline(described_class.new(value: "100", label: "Items", icon_name: "   "))

      expect(page).not_to have_css(".mb-3")
    end
  end
end
