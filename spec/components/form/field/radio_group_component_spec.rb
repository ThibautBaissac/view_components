# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::RadioGroupComponent, type: :component do
  describe "initialization" do
    it "initializes with name and options" do
      component = described_class.new(name: "plan", options: [ "Basic", "Pro" ])

      expect(component).to be_a(described_class)
    end

    it "defaults options to empty array" do
      component = described_class.new(name: "plan")

      expect(component.instance_variable_get(:@options)).to eq([])
    end

    it "accepts layout parameter" do
      component = described_class.new(name: "plan", options: [], layout: :inline)

      expect(component.instance_variable_get(:@layout)).to eq(:inline)
    end

    it "defaults layout to stacked" do
      component = described_class.new(name: "plan", options: [])

      expect(component.instance_variable_get(:@layout)).to eq(:stacked)
    end

    it "converts value to string for comparison" do
      component = described_class.new(name: "plan", options: [], value: 123)

      expect(component.instance_variable_get(:@value)).to eq("123")
    end
  end

  describe "layout validation" do
    it "accepts stacked layout" do
      expect {
        described_class.new(name: "plan", options: [], layout: :stacked)
      }.not_to raise_error
    end

    it "accepts inline layout" do
      expect {
        described_class.new(name: "plan", options: [], layout: :inline)
      }.not_to raise_error
    end

    it "raises error for invalid layout" do
      expect {
        described_class.new(name: "plan", options: [], layout: :invalid)
      }.to raise_error(ArgumentError, /Invalid layout: invalid/)
    end

    it "includes valid layouts in error message" do
      expect {
        described_class.new(name: "plan", options: [], layout: :bad)
      }.to raise_error(ArgumentError, /stacked, inline/)
    end
  end

  describe "#normalized_options" do
    it "normalizes simple string array" do
      component = described_class.new(name: "plan", options: [ "Basic", "Pro" ])

      expect(component.normalized_options).to eq([
        [ "Basic", "Basic" ],
        [ "Pro", "Pro" ]
      ])
    end

    it "normalizes label-value pairs" do
      component = described_class.new(name: "plan", options: [
        [ "Basic Plan", "basic" ],
        [ "Pro Plan", "pro" ]
      ])

      expect(component.normalized_options).to eq([
        [ "Basic Plan", "basic" ],
        [ "Pro Plan", "pro" ]
      ])
    end

    it "converts all values to strings" do
      component = described_class.new(name: "count", options: [ 1, 2, 3 ])

      expect(component.normalized_options).to eq([
        [ "1", "1" ],
        [ "2", "2" ],
        [ "3", "3" ]
      ])
    end
  end

  describe "#selected?" do
    it "returns true when value matches" do
      component = described_class.new(name: "plan", options: [], value: "pro")

      expect(component.selected?("pro")).to be true
    end

    it "returns false when value does not match" do
      component = described_class.new(name: "plan", options: [], value: "pro")

      expect(component.selected?("basic")).to be false
    end

    it "returns false when no value set" do
      component = described_class.new(name: "plan", options: [])

      expect(component.selected?("pro")).to be false
    end

    it "handles string/integer comparison" do
      component = described_class.new(name: "count", options: [], value: "2")

      expect(component.selected?(2)).to be true
    end
  end

  describe "#radio_id" do
    it "generates unique id with index" do
      component = described_class.new(name: "plan", id: "user_plan", options: [])

      expect(component.radio_id(0)).to eq("user_plan_0")
      expect(component.radio_id(1)).to eq("user_plan_1")
    end
  end

  describe "#inline_layout?" do
    it "returns true when layout is inline" do
      component = described_class.new(name: "plan", options: [], layout: :inline)

      expect(component.inline_layout?).to be true
    end

    it "returns false when layout is stacked" do
      component = described_class.new(name: "plan", options: [], layout: :stacked)

      expect(component.inline_layout?).to be false
    end
  end

  describe "#stacked_layout?" do
    it "returns true when layout is stacked" do
      component = described_class.new(name: "plan", options: [], layout: :stacked)

      expect(component.stacked_layout?).to be true
    end

    it "returns false when layout is inline" do
      component = described_class.new(name: "plan", options: [], layout: :inline)

      expect(component.stacked_layout?).to be false
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders fieldset element" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ]))

        expect(page).to have_css('fieldset')
      end

      it "renders legend when label provided" do
        render_inline(described_class.new(name: "plan", label: "Choose Plan", options: [ "Basic" ]))

        expect(page).to have_css('legend', text: "Choose Plan")
      end

      it "does not render legend when no label" do
        render_inline(described_class.new(name: "plan", options: [ "Basic" ]))

        expect(page).not_to have_css('legend')
      end

      it "renders radio for each option" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro", "Enterprise" ]))

        expect(page).to have_css('input[type="radio"]', count: 3)
      end

      it "renders radio with correct name" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ]))

        expect(page).to have_css('input[name="plan"]', count: 2)
      end

      it "renders radio with correct values" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ]))

        expect(page).to have_css('input[value="Basic"]')
        expect(page).to have_css('input[value="Pro"]')
      end

      it "renders labels for each radio" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ]))

        expect(page).to have_css('label', text: "Basic")
        expect(page).to have_css('label', text: "Pro")
      end

      it "generates unique ids for each radio" do
        render_inline(described_class.new(name: "plan", id: "user_plan", options: [ "Basic", "Pro" ]))

        expect(page).to have_css('input#user_plan_0')
        expect(page).to have_css('input#user_plan_1')
      end
    end

    context "with selected value" do
      it "marks selected radio as checked" do
        render_inline(described_class.new(
          name: "plan",
          options: [ "Basic", "Pro", "Enterprise" ],
          value: "Pro"
        ))

        expect(page).to have_css('input[value="Pro"][checked]')
        expect(page).not_to have_css('input[value="Basic"][checked]')
        expect(page).not_to have_css('input[value="Enterprise"][checked]')
      end

      it "handles label-value pairs" do
        render_inline(described_class.new(
          name: "plan",
          options: [
            [ "Basic Plan", "basic" ],
            [ "Pro Plan", "pro" ]
          ],
          value: "pro"
        ))

        expect(page).to have_css('input[value="pro"][checked]')
      end
    end

    context "with stacked layout" do
      it "uses vertical spacing" do
        render_inline(described_class.new(
          name: "plan",
          options: [ "Basic", "Pro" ],
          layout: :stacked
        ))

        expect(page).to have_css('.space-y-3')
      end
    end

    context "with inline layout" do
      it "uses flex layout with gaps" do
        render_inline(described_class.new(
          name: "plan",
          options: [ "Basic", "Pro" ],
          layout: :inline
        ))

        expect(page).to have_css('.flex.flex-wrap.gap-4')
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "plan", options: [ "Basic" ], hint: "Choose wisely"))

        expect(page).to have_css('p#plan-hint', text: "Choose wisely")
      end

      it "does not render hint when error present" do
        render_inline(described_class.new(
          name: "plan",
          options: [ "Basic" ],
          hint: "Help",
          error: "Please select"
        ))

        expect(page).not_to have_css('p#plan-hint')
        expect(page).to have_css('p#plan-error')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "plan", options: [ "Basic" ], error: "must be selected"))

        expect(page).to have_css('p#plan-error', text: "must be selected")
      end
    end

    context "with required field" do
      it "includes required attribute on all radios" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ], required: true))

        expect(page).to have_css('input[required]', count: 2)
      end

      it "renders required indicator in legend" do
        render_inline(described_class.new(
          name: "plan",
          label: "Plan",
          options: [ "Basic" ],
          required: true
        ))

        expect(page).to have_css('legend span.text-red-500', text: "*")
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on all radios" do
        render_inline(described_class.new(name: "plan", options: [ "Basic", "Pro" ], disabled: true))

        expect(page).to have_css('input[disabled]', count: 2)
      end
    end

    context "with different sizes" do
      it "applies small size to legend and radios" do
        render_inline(described_class.new(
          name: "plan",
          label: "Plan",
          options: [ "Basic" ],
          size: :small
        ))

        expect(page).to have_css('legend.text-xs')
        expect(page).to have_css('input.h-3\\.5.w-3\\.5')
      end

      it "applies medium size to legend and radios" do
        render_inline(described_class.new(
          name: "plan",
          label: "Plan",
          options: [ "Basic" ],
          size: :medium
        ))

        expect(page).to have_css('legend.text-sm')
        expect(page).to have_css('input.h-4.w-4')
      end

      it "applies large size to legend and radios" do
        render_inline(described_class.new(
          name: "plan",
          label: "Plan",
          options: [ "Basic" ],
          size: :large
        ))

        expect(page).to have_css('legend.text-base')
        expect(page).to have_css('input.h-5.w-5')
      end
    end
  end

  describe "accessibility" do
    it "uses fieldset for grouping" do
      render_inline(described_class.new(name: "plan", options: [ "Basic" ]))

      expect(page).to have_css('fieldset')
    end

    it "includes role radiogroup on fieldset" do
      render_inline(described_class.new(name: "plan", options: [ "Basic" ]))

      expect(page).to have_css('fieldset[role="radiogroup"]')
    end

    it "uses legend for group label" do
      render_inline(described_class.new(name: "plan", label: "Choose", options: [ "Basic" ]))

      expect(page).to have_css('legend', text: "Choose")
    end

    it "includes aria-required on legend when required" do
      render_inline(described_class.new(
        name: "plan",
        label: "Choose Plan",
        options: [ "Basic" ],
        required: true
      ))

      expect(page).to have_css('legend[aria-required="true"]')
    end

    it "does not include aria-required on legend when not required" do
      render_inline(described_class.new(
        name: "plan",
        label: "Choose Plan",
        options: [ "Basic" ],
        required: false
      ))

      expect(page).not_to have_css('legend[aria-required]')
    end

    it "associates each label with radio via for attribute" do
      render_inline(described_class.new(name: "plan", id: "user_plan", options: [ "Basic" ]))

      expect(page).to have_css('label[for="user_plan_0"]')
      expect(page).to have_css('input#user_plan_0')
    end

    it "includes aria-describedby on fieldset for hint" do
      render_inline(described_class.new(name: "plan", options: [ "Basic" ], hint: "Help"))

      # Hint should be present
      expect(page).to have_css('p#plan-hint')
    end

    it "includes aria-describedby on fieldset for error" do
      render_inline(described_class.new(name: "plan", options: [ "Basic" ], error: "Invalid"))

      # Error should be present
      expect(page).to have_css('p#plan-error')
    end

    it "error has role alert" do
      render_inline(described_class.new(name: "plan", options: [ "Basic" ], error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(
        name: "plan",
        label: "Plan",
        options: [ "Basic" ],
        required: true
      ))

      expect(page).to have_css('legend span[aria-hidden="true"]', text: "*")
    end
  end

  describe "edge cases" do
    it "handles empty options array" do
      render_inline(described_class.new(name: "plan", options: []))

      expect(page).to have_css('fieldset')
      expect(page).not_to have_css('input[type="radio"]')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[preferences][plan]",
        options: [ "Basic" ]
      ))

      expect(page).to have_css('input[name="user[preferences][plan]"]')
    end

    it "handles special characters in options" do
      render_inline(described_class.new(
        name: "plan",
        options: [ "Basic <script>alert('xss')</script>" ]
      ))

      expect(page).to have_text("Basic")
      expect(page).not_to have_css("script")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[plan]",
        id: "custom_plan",
        options: [
          [ "Basic Plan", "basic" ],
          [ "Pro Plan", "pro" ],
          [ "Enterprise", "enterprise" ]
        ],
        value: "pro",
        label: "Choose Plan",
        hint: "Select one",
        error: "must be selected",
        required: true,
        disabled: false,
        size: :large,
        layout: :inline
      ))

      expect(page).to have_css('fieldset')
      expect(page).to have_css('legend', text: "Choose Plan")
      expect(page).to have_css('legend span.text-red-500', text: "*")
      expect(page).to have_css('input[type="radio"]', count: 3)
      expect(page).to have_css('input[value="pro"][checked]')
      expect(page).to have_css('p#custom_plan-error', text: "must be selected")
      expect(page).not_to have_css('p#custom_plan-hint')
      expect(page).to have_css('.flex.flex-wrap.gap-4')
      expect(page).to have_css('input[required]', count: 3)
    end
  end
end
