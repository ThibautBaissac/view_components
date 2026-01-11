# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foundation::IconComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "user")

      expect(component.instance_variable_get(:@name)).to eq("user")
    end

    it "initializes with default set" do
      component = described_class.new(name: "user")

      expect(component.instance_variable_get(:@set)).to eq(:heroicons)
    end

    it "initializes with custom set" do
      component = described_class.new(name: "logo", set: :custom)

      expect(component.instance_variable_get(:@set)).to eq(:custom)
    end

    it "initializes with default variant" do
      component = described_class.new(name: "user")

      expect(component.instance_variable_get(:@variant)).to eq(:outline)
    end

    it "initializes with custom variant" do
      component = described_class.new(name: "user", variant: :solid)

      expect(component.instance_variable_get(:@variant)).to eq(:solid)
    end

    it "initializes with default size" do
      component = described_class.new(name: "user")

      expect(component.instance_variable_get(:@size)).to eq(:medium)
    end

    it "initializes with custom size" do
      component = described_class.new(name: "user", size: :large)

      expect(component.instance_variable_get(:@size)).to eq(:large)
    end

    it "initializes with default color" do
      component = described_class.new(name: "user")

      expect(component.instance_variable_get(:@color)).to eq(:current)
    end

    it "initializes with custom color" do
      component = described_class.new(name: "user", color: :primary)

      expect(component.instance_variable_get(:@color)).to eq(:primary)
    end

    it "initializes with label" do
      component = described_class.new(name: "user", label: "User profile")

      expect(component.instance_variable_get(:@label)).to eq("User profile")
    end

    it "initializes with custom SVG" do
      svg = '<svg><path d="M0 0"/></svg>'
      component = described_class.new(custom: svg)

      expect(component.instance_variable_get(:@custom)).to eq(svg)
    end
  end

  describe "parameter validation" do
    it "raises error when both name and custom are nil" do
      expect {
        described_class.new
      }.to raise_error(ArgumentError, /Either name or custom SVG content must be provided/)
    end

    it "accepts name without custom" do
      expect {
        described_class.new(name: "user")
      }.not_to raise_error
    end

    it "accepts custom without name" do
      expect {
        described_class.new(custom: "<svg></svg>")
      }.not_to raise_error
    end

    it "raises error for invalid set" do
      expect {
        described_class.new(name: "user", set: :invalid)
      }.to raise_error(ArgumentError, /Invalid icon set: invalid. Valid sets: heroicons, custom/)
    end

    it "raises error for invalid variant" do
      expect {
        described_class.new(name: "user", variant: :invalid)
      }.to raise_error(ArgumentError, /Invalid variant: invalid. Valid variants: outline, solid, mini, micro/)
    end

    it "raises error for invalid size" do
      expect {
        described_class.new(name: "user", size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size: invalid. Valid sizes:/)
    end

    it "raises error for invalid color" do
      expect {
        described_class.new(name: "user", color: :invalid)
      }.to raise_error(ArgumentError, /Invalid color: invalid. Valid colors:/)
    end
  end

  describe "set validation" do
    it "accepts heroicons set" do
      expect {
        described_class.new(name: "user", set: :heroicons)
      }.not_to raise_error
    end

    it "accepts custom set" do
      expect {
        described_class.new(name: "logo", set: :custom)
      }.not_to raise_error
    end
  end

  describe "variant validation" do
    it "accepts all valid variants" do
      %i[outline solid mini micro].each do |variant|
        expect {
          described_class.new(name: "user", variant: variant)
        }.not_to raise_error
      end
    end
  end

  describe "size validation" do
    it "accepts all valid sizes" do
      %i[xs small medium large xl xxl].each do |size|
        expect {
          described_class.new(name: "user", size: size)
        }.not_to raise_error
      end
    end
  end

  describe "color validation" do
    it "accepts all valid colors" do
      %i[current primary secondary success warning danger info muted white black].each do |color|
        expect {
          described_class.new(name: "user", color: color)
        }.not_to raise_error
      end
    end
  end

  describe "rendering with custom SVG" do
    let(:simple_svg) { '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M0 0h24v24H0z"/></svg>' }

    it "renders custom SVG content" do
      render_inline(described_class.new(custom: simple_svg))

      expect(page).to have_css("svg")
    end

    it "applies size classes to custom SVG" do
      render_inline(described_class.new(custom: simple_svg, size: :large))

      expect(page).to have_css("svg.w-6.h-6")
    end

    it "applies color classes to custom SVG" do
      render_inline(described_class.new(custom: simple_svg, color: :primary))

      expect(page).to have_css("svg.text-blue-600")
    end

    it "applies custom CSS class to custom SVG" do
      render_inline(described_class.new(custom: simple_svg, class: "custom-icon"))

      expect(page).to have_css("svg.custom-icon")
    end
  end

  describe "accessibility" do
    let(:simple_svg) { '<svg><path d="M0 0"/></svg>' }

    context "without label (decorative icon)" do
      it "includes aria-hidden true" do
        render_inline(described_class.new(custom: simple_svg))

        expect(page).to have_css('svg[aria-hidden="true"]')
      end

      it "includes focusable false" do
        render_inline(described_class.new(custom: simple_svg))

        expect(page).to have_css('svg[focusable="false"]')
      end

      it "does not include role" do
        render_inline(described_class.new(custom: simple_svg))

        expect(page).not_to have_css('svg[role="img"]')
      end
    end

    context "with label (semantic icon)" do
      it "includes role img" do
        render_inline(described_class.new(custom: simple_svg, label: "User profile"))

        expect(page).to have_css('svg[role="img"]')
      end

      it "includes aria-label" do
        render_inline(described_class.new(custom: simple_svg, label: "User profile"))

        expect(page).to have_css('svg[aria-label="User profile"]')
      end

      it "does not include aria-hidden" do
        render_inline(described_class.new(custom: simple_svg, label: "User profile"))

        expect(page).not_to have_css('svg[aria-hidden]')
      end

      it "does not include focusable" do
        render_inline(described_class.new(custom: simple_svg, label: "User profile"))

        expect(page).not_to have_css('svg[focusable]')
      end
    end
  end

  describe "size classes" do
    let(:simple_svg) { '<svg><path d="M0 0"/></svg>' }

    it "applies xs size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :xs))

      expect(page).to have_css("svg.w-3.h-3")
    end

    it "applies small size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :small))

      expect(page).to have_css("svg.w-4.h-4")
    end

    it "applies medium size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :medium))

      expect(page).to have_css("svg.w-5.h-5")
    end

    it "applies large size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :large))

      expect(page).to have_css("svg.w-6.h-6")
    end

    it "applies xl size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :xl))

      expect(page).to have_css("svg.w-8.h-8")
    end

    it "applies xxl size classes" do
      render_inline(described_class.new(custom: simple_svg, size: :xxl))

      expect(page).to have_css("svg.w-10.h-10")
    end
  end

  describe "color classes" do
    let(:simple_svg) { '<svg><path d="M0 0"/></svg>' }

    it "applies current color" do
      render_inline(described_class.new(custom: simple_svg, color: :current))

      expect(page).to have_css("svg.text-current")
    end

    it "applies primary color" do
      render_inline(described_class.new(custom: simple_svg, color: :primary))

      expect(page).to have_css("svg.text-blue-600")
    end

    it "applies secondary color" do
      render_inline(described_class.new(custom: simple_svg, color: :secondary))

      expect(page).to have_css("svg.text-gray-600")
    end

    it "applies success color" do
      render_inline(described_class.new(custom: simple_svg, color: :success))

      expect(page).to have_css("svg.text-green-600")
    end

    it "applies warning color" do
      render_inline(described_class.new(custom: simple_svg, color: :warning))

      expect(page).to have_css("svg.text-yellow-600")
    end

    it "applies danger color" do
      render_inline(described_class.new(custom: simple_svg, color: :danger))

      expect(page).to have_css("svg.text-red-600")
    end

    it "applies info color" do
      render_inline(described_class.new(custom: simple_svg, color: :info))

      expect(page).to have_css("svg.text-cyan-600")
    end

    it "applies muted color" do
      render_inline(described_class.new(custom: simple_svg, color: :muted))

      expect(page).to have_css("svg.text-gray-400")
    end

    it "applies white color" do
      render_inline(described_class.new(custom: simple_svg, color: :white))

      expect(page).to have_css("svg.text-white")
    end

    it "applies black color" do
      render_inline(described_class.new(custom: simple_svg, color: :black))

      expect(page).to have_css("svg.text-gray-900")
    end
  end

  describe "HTML attributes" do
    let(:simple_svg) { '<svg><path d="M0 0"/></svg>' }

    it "applies custom CSS class" do
      render_inline(described_class.new(custom: simple_svg, class: "custom-icon"))

      expect(page).to have_css("svg.custom-icon")
    end

    it "applies data attributes" do
      render_inline(described_class.new(custom: simple_svg, data: { testid: "icon" }))

      expect(page).to have_css('svg[data-testid="icon"]')
    end

    it "applies custom attributes" do
      render_inline(described_class.new(custom: simple_svg, id: "user-icon"))

      expect(page).to have_css("svg#user-icon")
    end
  end

  describe "#render?" do
    it "returns true when custom SVG is provided" do
      component = described_class.new(custom: "<svg></svg>")

      expect(component.render?).to be true
    end

    it "returns true when name is provided and file exists" do
      component = described_class.new(name: "user")
      allow(IconLoaderService).to receive(:icon_exists?).and_return(true)

      expect(component.render?).to be true
    end

    it "returns false when name is provided but file does not exist" do
      component = described_class.new(name: "nonexistent")
      allow(IconLoaderService).to receive(:icon_exists?).and_return(false)

      expect(component.render?).to be false
    end
  end

  describe "SVG sanitization" do
    it "sanitizes malicious SVG content" do
      malicious_svg = '<svg xmlns="http://www.w3.org/2000/svg"><script>alert("xss")</script><path d="M0 0"/></svg>'

      render_inline(described_class.new(custom: malicious_svg))

      expect(page).to have_css("svg")
      expect(page).not_to have_css("script")
      # Script content should be removed by sanitizer
    end

    it "allows safe SVG elements" do
      safe_svg = '<svg><g><circle cx="10" cy="10" r="5"/><rect x="0" y="0" width="20" height="20"/></g></svg>'

      render_inline(described_class.new(custom: safe_svg))

      expect(page).to have_css("svg")
      expect(page).to have_css("g")
      expect(page).to have_css("circle")
      expect(page).to have_css("rect")
    end

    it "allows safe SVG attributes" do
      svg_with_attrs = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M0 0" stroke-width="2"/></svg>'

      render_inline(described_class.new(custom: svg_with_attrs))

      expect(page).to have_css("svg")
      # Attributes should be preserved after sanitization
    end
  end

  describe "class methods" do
    describe ".icon_directory" do
      it "returns correct directory for heroicons outline" do
        dir = described_class.icon_directory(:heroicons, :outline)

        expect(dir.to_s).to end_with("app/assets/icons/heroicons/outline")
      end

      it "returns correct directory for heroicons solid" do
        dir = described_class.icon_directory(:heroicons, :solid)

        expect(dir.to_s).to end_with("app/assets/icons/heroicons/solid")
      end

      it "returns correct directory for custom icons" do
        dir = described_class.icon_directory(:custom, :outline)

        expect(dir.to_s).to end_with("app/assets/icons/custom")
      end
    end

    describe ".available_icons" do
      it "returns empty array when directory does not exist" do
        allow(Dir).to receive(:exist?).and_return(false)

        icons = described_class.available_icons(set: :heroicons, variant: :outline)

        expect(icons).to eq([])
      end

      it "returns sorted list of icon names when directory exists" do
        allow(Dir).to receive(:exist?).and_return(true)
        allow(Dir).to receive(:glob).and_return([
          "/path/to/icons/user.svg",
          "/path/to/icons/home.svg",
          "/path/to/icons/settings.svg"
        ])

        icons = described_class.available_icons(set: :heroicons, variant: :outline)

        expect(icons).to eq(%w[home settings user])
      end
    end

    describe ".clear_cache!" do
      it "deletes matched cache entries" do
        expect(Rails.cache).to receive(:delete_matched).with("foundation_icon/*")

        described_class.clear_cache!
      end
    end
  end

  describe "edge cases" do
    let(:simple_svg) { '<svg><path d="M0 0"/></svg>' }

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        custom: simple_svg,
        size: :large,
        color: :primary,
        label: "User profile",
        class: "profile-icon",
        id: "user-icon",
        data: { controller: "tooltip" }
      ))

      expect(page).to have_css("svg#user-icon.profile-icon")
      expect(page).to have_css("svg.w-6.h-6.text-blue-600")
      expect(page).to have_css('svg[role="img"][aria-label="User profile"]')
      expect(page).to have_css('svg[data-controller="tooltip"]')
    end

    it "handles empty custom SVG gracefully" do
      # Empty string is considered blank, so validation will raise error
      # This test verifies that blank SVG content behaves correctly
      svg_with_empty_content = '<svg xmlns="http://www.w3.org/2000/svg"></svg>'
      component = described_class.new(custom: svg_with_empty_content)

      # Should render an empty SVG element
      render_inline(component)
      expect(page).to have_css("svg")
    end

    it "handles all size and color combinations" do
      %i[xs small medium large xl xxl].each do |size|
        %i[current primary secondary success danger].each do |color|
          expect {
            render_inline(described_class.new(custom: simple_svg, size: size, color: color))
          }.not_to raise_error
        end
      end
    end

    it "preserves existing SVG classes" do
      svg_with_class = '<svg class="existing-class"><path d="M0 0"/></svg>'

      render_inline(described_class.new(custom: svg_with_class, class: "new-class", size: :medium))

      expect(page).to have_css("svg.existing-class")
      expect(page).to have_css("svg.new-class")
      expect(page).to have_css("svg.w-5.h-5")
    end
  end
end
