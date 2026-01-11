# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::DividerComponent, type: :component do
  describe "initialization" do
    it "initializes with default orientation" do
      component = described_class.new

      expect(component.instance_variable_get(:@orientation)).to eq(:horizontal)
    end

    it "initializes with custom orientation" do
      component = described_class.new(orientation: :vertical)

      expect(component.instance_variable_get(:@orientation)).to eq(:vertical)
    end

    it "initializes with default thickness" do
      component = described_class.new

      expect(component.instance_variable_get(:@thickness)).to eq(:hairline)
    end

    it "initializes with custom thickness" do
      component = described_class.new(thickness: :thick)

      expect(component.instance_variable_get(:@thickness)).to eq(:thick)
    end

    it "initializes with default color" do
      component = described_class.new

      expect(component.instance_variable_get(:@color)).to eq(:default)
    end

    it "initializes with custom color" do
      component = described_class.new(color: :primary)

      expect(component.instance_variable_get(:@color)).to eq(:primary)
    end

    it "initializes with default spacing" do
      component = described_class.new

      expect(component.instance_variable_get(:@spacing)).to eq(:medium)
    end

    it "initializes with custom spacing" do
      component = described_class.new(spacing: :large)

      expect(component.instance_variable_get(:@spacing)).to eq(:large)
    end
  end

  describe "orientation validation" do
    it "accepts valid horizontal orientation" do
      expect {
        described_class.new(orientation: :horizontal)
      }.not_to raise_error
    end

    it "accepts valid vertical orientation" do
      expect {
        described_class.new(orientation: :vertical)
      }.not_to raise_error
    end

    it "raises error for invalid orientation" do
      expect {
        described_class.new(orientation: :diagonal)
      }.to raise_error(ArgumentError, /Invalid orientation: diagonal. Must be one of: horizontal, vertical/)
    end
  end

  describe "thickness validation" do
    it "accepts valid hairline thickness" do
      expect {
        described_class.new(thickness: :hairline)
      }.not_to raise_error
    end

    it "accepts valid thin thickness" do
      expect {
        described_class.new(thickness: :thin)
      }.not_to raise_error
    end

    it "accepts valid medium thickness" do
      expect {
        described_class.new(thickness: :medium)
      }.not_to raise_error
    end

    it "accepts valid thick thickness" do
      expect {
        described_class.new(thickness: :thick)
      }.not_to raise_error
    end

    it "raises error for invalid thickness" do
      expect {
        described_class.new(thickness: :invalid)
      }.to raise_error(ArgumentError, /Invalid thickness: invalid. Must be one of: hairline, thin, medium, thick/)
    end
  end

  describe "color validation" do
    it "accepts all valid colors" do
      %i[default muted primary secondary success warning danger].each do |color|
        expect {
          described_class.new(color: color)
        }.not_to raise_error
      end
    end

    it "raises error for invalid color" do
      expect {
        described_class.new(color: :invalid)
      }.to raise_error(ArgumentError, /Invalid color: invalid. Must be one of:/)
    end
  end

  describe "spacing validation" do
    it "accepts all valid spacings" do
      %i[none small medium large xlarge].each do |spacing|
        expect {
          described_class.new(spacing: spacing)
        }.not_to raise_error
      end
    end

    it "raises error for invalid spacing" do
      expect {
        described_class.new(spacing: :invalid)
      }.to raise_error(ArgumentError, /Invalid spacing: invalid. Must be one of:/)
    end
  end

  describe "rendering" do
    context "without label (decorative divider)" do
      it "renders horizontal divider by default" do
        render_inline(described_class.new)

        expect(page).to have_css('hr.w-full')
        expect(page).to have_css('hr.border-t')
      end

      it "renders vertical divider" do
        render_inline(described_class.new(orientation: :vertical))

        expect(page).to have_css('div.h-full')
        expect(page).to have_css('div.border-l')
      end

      it "renders with default color" do
        render_inline(described_class.new)

        expect(page).to have_css('hr.border-slate-300')
      end

      it "renders with primary color" do
        render_inline(described_class.new(color: :primary))

        expect(page).to have_css('hr.border-indigo-500')
      end

      it "renders with danger color" do
        render_inline(described_class.new(color: :danger))

        expect(page).to have_css('hr.border-red-500')
      end

      it "renders with hairline thickness" do
        render_inline(described_class.new(thickness: :hairline))

        expect(page).to have_css('hr.border-t')
      end

      it "renders with thick thickness" do
        render_inline(described_class.new(thickness: :thick))

        expect(page).to have_css('hr.border-t-8')
      end

      it "renders with medium spacing" do
        render_inline(described_class.new(spacing: :medium))

        expect(page).to have_css('hr.my-4')
      end

      it "renders with large spacing" do
        render_inline(described_class.new(spacing: :large))

        expect(page).to have_css('hr.my-6')
      end

      it "renders with no spacing" do
        render_inline(described_class.new(spacing: :none))

        expect(page).to have_css('hr.my-0')
      end
    end

    context "with label content" do
      it "renders divider with label" do
        component = described_class.new

        render_inline(component) do
          "OR"
        end

        expect(page).to have_text("OR")
      end

      it "renders horizontal divider with label in flex container" do
        component = described_class.new

        render_inline(component) do
          "OR"
        end

        expect(page).to have_css('.flex.items-center')
        expect(page).to have_css('.px-3.text-sm.font-medium.text-slate-600')
      end

      it "renders vertical divider with label in flex column" do
        component = described_class.new(orientation: :vertical)

        render_inline(component) do
          "OR"
        end

        expect(page).to have_css('.flex.flex-col.items-center')
        expect(page).to have_css('.py-3.text-sm.font-medium.text-slate-600')
      end

      it "renders lines on both sides of label" do
        component = described_class.new

        render_inline(component) do
          "OR"
        end

        # Should have multiple elements with flex-grow
        expect(page).to have_css('.flex-grow', count: 2)
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        render_inline(described_class.new(class: "custom-divider"))

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css('hr.w-full')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(data: { testid: "my-divider" }))

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css('hr[data-testid="my-divider"]')
      end

      it "renders with custom ID" do
        render_inline(described_class.new(id: "section-divider"))

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css("hr#section-divider")
      end
    end
  end

  describe "accessibility" do
    context "without label (decorative)" do
      it "includes role presentation" do
        render_inline(described_class.new)

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css('hr[role="presentation"]')
      end

      it "includes aria-hidden true" do
        render_inline(described_class.new)

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css('hr[aria-hidden="true"]')
      end
    end

    context "with label (semantic separator)" do
      it "includes role separator" do
        component = described_class.new

        render_inline(component) do
          "OR"
        end

        expect(page).to have_css('[role="separator"]')
      end

      it "includes aria-orientation for horizontal" do
        component = described_class.new(orientation: :horizontal)

        render_inline(component) do
          "OR"
        end

        expect(page).to have_css('[aria-orientation="horizontal"]')
      end

      it "includes aria-orientation for vertical" do
        component = described_class.new(orientation: :vertical)

        render_inline(component) do
          "OR"
        end

        expect(page).to have_css('[aria-orientation="vertical"]')
      end

      it "does not include aria-hidden when has label" do
        component = described_class.new

        render_inline(component) do
          "OR"
        end

        expect(page).not_to have_css('[aria-hidden="true"]')
      end
    end
  end

  describe "#has_label?" do
    it "returns false when no content provided" do
      component = described_class.new

      expect(component.has_label?).to be false
    end

    it "returns true when content provided" do
      component = described_class.new

      render_inline(component) do
        "Label"
      end

      expect(component.has_label?).to be true
    end
  end

  describe "#horizontal?" do
    it "returns true for horizontal orientation" do
      component = described_class.new(orientation: :horizontal)

      expect(component.send(:horizontal?)).to be true
    end

    it "returns false for vertical orientation" do
      component = described_class.new(orientation: :vertical)

      expect(component.send(:horizontal?)).to be false
    end
  end

  describe "#vertical?" do
    it "returns true for vertical orientation" do
      component = described_class.new(orientation: :vertical)

      expect(component.send(:vertical?)).to be true
    end

    it "returns false for horizontal orientation" do
      component = described_class.new(orientation: :horizontal)

      expect(component.send(:vertical?)).to be false
    end
  end

  describe "edge cases" do
    it "combines multiple configuration options without label" do
      render_inline(described_class.new(
        orientation: :horizontal,
        thickness: :thick,
        color: :primary,
        spacing: :large,
        id: "my-divider"
      ))

      # Horizontal divider without label uses <hr> element
      expect(page).to have_css('hr.border-t-8.border-indigo-500.my-6')
      expect(page).to have_css('hr#my-divider')
      expect(page).to have_css('hr[role="presentation"]')
    end

    it "combines multiple configuration options with label" do
      component = described_class.new(
        orientation: :horizontal,
        thickness: :medium,
        color: :secondary,
        spacing: :small,
        class: "form-section"
      )

      render_inline(component) do
        "Section 2"
      end

      expect(page).to have_text("Section 2")
      expect(page).to have_css('.flex.items-center.my-2')
      expect(page).to have_css('.flex-grow.border-t-4.border-slate-400')
      expect(page).to have_css('[role="separator"]')
    end

    it "handles all orientation and thickness combinations" do
      %i[horizontal vertical].each do |orientation|
        %i[hairline thin medium thick].each do |thickness|
          expect {
            render_inline(described_class.new(orientation: orientation, thickness: thickness))
          }.not_to raise_error
        end
      end
    end

    it "handles all color options" do
      %i[default muted primary secondary success warning danger].each do |color|
        render_inline(described_class.new(color: color))

        # Horizontal divider without label uses <hr> element
        expect(page).to have_css('hr')
      end
    end

    it "handles vertical divider with all thickness options" do
      %i[hairline thin medium thick].each do |thickness|
        render_inline(described_class.new(orientation: :vertical, thickness: thickness))

        expect(page).to have_css('div.h-full')
      end
    end
  end
end
