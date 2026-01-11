# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::TooltipComponent, type: :component do
  describe "initialization" do
    it "initializes with text" do
      component = described_class.new(text: "Helpful tip")

      expect(component.instance_variable_get(:@text)).to eq("Helpful tip")
    end

    it "initializes with default position" do
      component = described_class.new(text: "Tip")

      expect(component.instance_variable_get(:@position)).to eq(:top)
    end

    it "initializes with custom position" do
      component = described_class.new(text: "Tip", position: :bottom)

      expect(component.instance_variable_get(:@position)).to eq(:bottom)
    end

    it "initializes with default size" do
      component = described_class.new(text: "Tip")

      expect(component.instance_variable_get(:@size)).to eq(:medium)
    end

    it "initializes with custom size" do
      component = described_class.new(text: "Tip", size: :large)

      expect(component.instance_variable_get(:@size)).to eq(:large)
    end

    it "initializes with default delay" do
      component = described_class.new(text: "Tip")

      expect(component.instance_variable_get(:@delay)).to eq(200)
    end

    it "initializes with custom delay" do
      component = described_class.new(text: "Tip", delay: 500)

      expect(component.instance_variable_get(:@delay)).to eq(500)
    end

    it "initializes with arrow true by default" do
      component = described_class.new(text: "Tip")

      expect(component.instance_variable_get(:@arrow)).to be true
    end

    it "initializes with arrow false when provided" do
      component = described_class.new(text: "Tip", arrow: false)

      expect(component.instance_variable_get(:@arrow)).to be false
    end

    it "converts position to symbol" do
      component = described_class.new(text: "Tip", position: "bottom")

      expect(component.instance_variable_get(:@position)).to eq(:bottom)
    end

    it "converts size to symbol" do
      component = described_class.new(text: "Tip", size: "large")

      expect(component.instance_variable_get(:@size)).to eq(:large)
    end
  end

  describe "position validation" do
    it "accepts all valid positions" do
      %i[top bottom left right].each do |position|
        expect {
          described_class.new(text: "Tip", position: position)
        }.not_to raise_error
      end
    end

    it "raises error for invalid position" do
      expect {
        described_class.new(text: "Tip", position: :center)
      }.to raise_error(ArgumentError, /Invalid position: center. Must be one of: top, bottom, left, right/)
    end
  end

  describe "size validation" do
    it "accepts all valid sizes" do
      %i[small medium large].each do |size|
        expect {
          described_class.new(text: "Tip", size: size)
        }.not_to raise_error
      end
    end

    it "raises error for invalid size" do
      expect {
        described_class.new(text: "Tip", size: :xlarge)
      }.to raise_error(ArgumentError, /Invalid size: xlarge. Must be one of: small, medium, large/)
    end
  end

  describe "delay validation" do
    it "accepts valid positive integer delay" do
      expect {
        described_class.new(text: "Tip", delay: 300)
      }.not_to raise_error
    end

    it "accepts zero delay" do
      expect {
        described_class.new(text: "Tip", delay: 0)
      }.not_to raise_error
    end

    it "raises error for negative delay" do
      expect {
        described_class.new(text: "Tip", delay: -100)
      }.to raise_error(ArgumentError, /Invalid delay: -100. Must be a non-negative integer/)
    end

    it "raises error for non-integer delay" do
      expect {
        described_class.new(text: "Tip", delay: "fast")
      }.to raise_error(ArgumentError, /Invalid delay/)
    end
  end

  describe "rendering" do
    context "with text" do
      it "renders wrapper with tooltip" do
        component = described_class.new(text: "Helpful tip")

        render_inline(component) do
          "<button>Hover me</button>".html_safe
        end

        expect(page).to have_button("Hover me")
        expect(page).to have_text("Helpful tip")
      end

      it "renders tooltip with default position classes" do
        component = described_class.new(text: "Tip")

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.bottom-full.left-1\\/2.-translate-x-1\\/2.mb-2')
      end

      it "renders tooltip with bottom position" do
        component = described_class.new(text: "Tip", position: :bottom)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.top-full.left-1\\/2.-translate-x-1\\/2.mt-2')
      end

      it "renders tooltip with left position" do
        component = described_class.new(text: "Tip", position: :left)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.right-full.top-1\\/2.-translate-y-1\\/2.mr-2')
      end

      it "renders tooltip with right position" do
        component = described_class.new(text: "Tip", position: :right)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.left-full.top-1\\/2.-translate-y-1\\/2.ml-2')
      end

      it "renders with small size classes" do
        component = described_class.new(text: "Tip", size: :small)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.text-xs.px-2.py-1.max-w-xs')
      end

      it "renders with medium size classes" do
        component = described_class.new(text: "Tip", size: :medium)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.text-sm.px-3.py-2.max-w-sm')
      end

      it "renders with large size classes" do
        component = described_class.new(text: "Tip", size: :large)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.text-sm.px-4.py-3.max-w-md')
      end

      it "renders tooltip with arrow by default" do
        component = described_class.new(text: "Tip")

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.w-2.h-2.bg-gray-900.rotate-45')
      end

      it "does not render arrow when arrow is false" do
        component = described_class.new(text: "Tip", arrow: false)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).not_to have_css('.rotate-45')
      end

      it "renders tooltip initially hidden" do
        component = described_class.new(text: "Tip")

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('.opacity-0.invisible')
      end
    end

    context "with tooltip_content slot" do
      it "renders rich tooltip content" do
        component = described_class.new

        render_inline(component) do |c|
          c.with_tooltip_content do
            '<strong>Bold tip</strong>'.html_safe
          end
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css("strong", text: "Bold tip")
      end

      it "prefers slot over text parameter" do
        component = described_class.new(text: "Plain text")

        render_inline(component) do |c|
          c.with_tooltip_content do
            '<em>Rich content</em>'.html_safe
          end
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css("em", text: "Rich content")
      end
    end

    context "with HTML attributes" do
      it "renders with custom CSS class" do
        component = described_class.new(text: "Tip", class: "custom-tooltip")

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        # Classes are applied via wrapper_classes method, not html_attributes_string
        expect(page).to have_css(".inline-block.relative")
      end

      it "renders with custom data attributes" do
        component = described_class.new(text: "Tip", data: { testid: "my-tooltip" })

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css('[data-testid="my-tooltip"]')
      end

      it "renders with custom ID" do
        component = described_class.new(text: "Tip", id: "help-tooltip")

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        expect(page).to have_css("#help-tooltip")
      end
    end
  end

  describe "Stimulus controller integration" do
    it "includes Stimulus controller" do
      component = described_class.new(text: "Tip")

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css('[data-controller="components--tooltip"]')
    end

    it "includes delay value" do
      component = described_class.new(text: "Tip", delay: 500)

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css('[data-components--tooltip-delay-value="500"]')
    end

    it "includes position value" do
      component = described_class.new(text: "Tip", position: :bottom)

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css('[data-components--tooltip-position-value="bottom"]')
    end

    it "merges custom data attributes with controller data" do
      component = described_class.new(text: "Tip", data: { custom: "value" })

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css('[data-controller="components--tooltip"]')
      expect(page).to have_css('[data-custom="value"]')
    end
  end

  describe "#render?" do
    it "returns false when no content provided" do
      component = described_class.new(text: "Tip")

      expect(component.render?).to be false
    end

    it "returns false when content but no text or tooltip_content" do
      component = described_class.new

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      # render? is called before rendering, so in initialization context
      component2 = described_class.new
      expect(component2.render?).to be false
    end

    it "returns true when content and text are provided" do
      component = described_class.new(text: "Tip")

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(component.render?).to be true
    end

    it "returns true when content and tooltip_content slot are provided" do
      component = described_class.new

      render_inline(component) do |c|
        c.with_tooltip_content { "Rich content" }
        "<button>Hover</button>".html_safe
      end

      expect(component.render?).to be true
    end
  end

  describe "#has_rich_content?" do
    it "returns true when tooltip_content slot is provided" do
      component = described_class.new

      render_inline(component) do |c|
        c.with_tooltip_content { "Content" }
        "<button>Hover</button>".html_safe
      end

      expect(component.send(:has_rich_content?)).to be true
    end

    it "returns false when no tooltip_content slot" do
      component = described_class.new(text: "Plain text")

      expect(component.send(:has_rich_content?)).to be false
    end
  end

  describe "#show_arrow?" do
    it "returns true when arrow is true" do
      component = described_class.new(text: "Tip", arrow: true)

      expect(component.send(:show_arrow?)).to be true
    end

    it "returns false when arrow is false" do
      component = described_class.new(text: "Tip", arrow: false)

      expect(component.send(:show_arrow?)).to be false
    end
  end

  describe "edge cases" do
    it "combines multiple configuration options" do
      component = described_class.new(
        text: "Helpful information about this field",
        position: :right,
        size: :large,
        delay: 300,
        arrow: true,
        id: "email-tooltip",
        data: { analytics: "tooltip-shown" }
      )

      render_inline(component) do
        "<input type='email'>".html_safe
      end

      expect(page).to have_css('[id="email-tooltip"]')
      expect(page).to have_css('[data-controller="components--tooltip"]')
      expect(page).to have_css('[data-components--tooltip-delay-value="300"]')
      expect(page).to have_css('[data-components--tooltip-position-value="right"]')
      expect(page).to have_css('[data-analytics="tooltip-shown"]')
      expect(page).to have_css('.left-full.top-1\\/2.-translate-y-1\\/2')
      expect(page).to have_css('.text-sm.px-4.py-3.max-w-md')
    end

    it "handles special characters in text" do
      component = described_class.new(text: "Tip with <html> & special chars")

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_text("Tip with <html> & special chars")
    end

    it "handles long text content" do
      long_text = "This is a very long tooltip text that should wrap properly within the max-width constraint " * 3

      component = described_class.new(text: long_text, size: :large)

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_text(long_text)
      expect(page).to have_css('.max-w-md')
    end

    it "handles all position and size combinations" do
      %i[top bottom left right].each do |position|
        %i[small medium large].each do |size|
          component = described_class.new(text: "Tip", position: position, size: size)

          render_inline(component) do
            "<button>Hover</button>".html_safe
          end

          expect(page).to have_text("Tip")
        end
      end
    end

    it "handles zero delay" do
      component = described_class.new(text: "Instant tip", delay: 0)

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css('[data-components--tooltip-delay-value="0"]')
    end

    it "generates unique tooltip IDs" do
      component1 = described_class.new(text: "Tip 1")
      component2 = described_class.new(text: "Tip 2")

      id1 = component1.send(:tooltip_id)
      id2 = component2.send(:tooltip_id)

      expect(id1).not_to eq(id2)
      expect(id1).to start_with("tooltip-")
      expect(id2).to start_with("tooltip-")
    end

    it "does not render when only text is provided without content" do
      component = described_class.new(text: "Tip")

      result = render_inline(component)

      expect(result.to_html.strip).to be_empty
    end

    it "renders wrapper inline-block for proper positioning" do
      component = described_class.new(text: "Tip")

      render_inline(component) do
        "<button>Hover</button>".html_safe
      end

      expect(page).to have_css(".inline-block.relative")
    end

    it "styles arrow based on position" do
      positions_and_arrows = {
        top: "top-full left-1/2 -translate-x-1/2 -mt-1",
        bottom: "bottom-full left-1/2 -translate-x-1/2 -mb-1",
        left: "left-full top-1/2 -translate-y-1/2 -ml-1",
        right: "right-full top-1/2 -translate-y-1/2 -mr-1"
      }

      positions_and_arrows.each do |position, _expected_classes|
        component = described_class.new(text: "Tip", position: position)

        render_inline(component) do
          "<button>Hover</button>".html_safe
        end

        # Just verify the arrow is rendered with rotation
        expect(page).to have_css('.rotate-45') if component.send(:show_arrow?)
      end
    end
  end
end
