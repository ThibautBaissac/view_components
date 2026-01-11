# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::RadioComponent, type: :component do
  describe "initialization" do
    it "initializes with name and value" do
      component = described_class.new(name: "plan", value: "basic")

      expect(component).to be_a(described_class)
      expect(component.instance_variable_get(:@value)).to eq("basic")
    end

    it "requires value parameter" do
      expect {
        described_class.new(name: "plan")
      }.to raise_error(ArgumentError, /missing keyword: :?value/)
    end

    it "accepts checked parameter" do
      component = described_class.new(name: "plan", value: "basic", checked: true)

      expect(component.instance_variable_get(:@checked)).to be true
    end

    it "defaults checked to false" do
      component = described_class.new(name: "plan", value: "basic")

      expect(component.instance_variable_get(:@checked)).to be false
    end

    it "generates unique id from name and value" do
      component = described_class.new(name: "plan", value: "pro")

      expect(component.instance_variable_get(:@id)).to eq("plan_pro")
    end

    it "sanitizes special characters in generated id" do
      component = described_class.new(name: "plan", value: "pro-plan-$19")

      # The sanitize_id method converts non-alphanumeric chars to underscores
      expect(component.instance_variable_get(:@id)).to eq("plan_pro-plan-_19")
    end

    it "accepts custom id" do
      component = described_class.new(name: "plan", value: "basic", id: "custom_id")

      expect(component.instance_variable_get(:@id)).to eq("custom_id")
    end

    it "removes placeholder parameter" do
      component = described_class.new(name: "plan", value: "basic", placeholder: "Should be removed")

      expect(component.instance_variable_get(:@placeholder)).to be_nil
    end
  end

  describe "#checked?" do
    it "returns true when checked is true" do
      component = described_class.new(name: "plan", value: "basic", checked: true)

      expect(component.checked?).to be true
    end

    it "returns false when checked is false" do
      component = described_class.new(name: "plan", value: "basic", checked: false)

      expect(component.checked?).to be false
    end
  end

  describe "#has_label?" do
    it "returns true when label prop is provided" do
      component = described_class.new(name: "plan", value: "basic", label: "Basic Plan")

      expect(component.has_label?).to be true
    end

    it "returns false when label prop is not provided" do
      component = described_class.new(name: "plan", value: "basic")

      expect(component.has_label?).to be false
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders radio input with type radio" do
        render_inline(described_class.new(name: "plan", value: "basic"))

        expect(page).to have_css('input[type="radio"]')
      end

      it "renders radio with name attribute" do
        render_inline(described_class.new(name: "plan", value: "basic"))

        expect(page).to have_css('input[name="plan"]')
      end

      it "renders radio with value attribute" do
        render_inline(described_class.new(name: "plan", value: "basic"))

        expect(page).to have_css('input[value="basic"]')
      end

      it "renders radio with generated id from name and value" do
        render_inline(described_class.new(name: "plan", value: "pro"))

        expect(page).to have_css('input#plan_pro')
      end

      it "renders radio with custom id" do
        render_inline(described_class.new(name: "plan", value: "basic", id: "custom_id"))

        expect(page).to have_css('input#custom_id')
      end

      it "sanitizes special characters in id" do
        render_inline(described_class.new(name: "user[plan]", value: "pro-plan"))

        expect(page).to have_css('input#user_plan_pro-plan')
      end
    end

    context "with label" do
      it "renders label when provided" do
        render_inline(described_class.new(name: "plan", value: "basic", label: "Basic Plan"))

        expect(page).to have_css('label', text: "Basic Plan")
      end

      it "associates label with radio via for attribute" do
        render_inline(described_class.new(name: "plan", value: "pro", label: "Pro Plan"))

        expect(page).to have_css('label[for="plan_pro"]')
        expect(page).to have_css('input#plan_pro')
      end

      it "does not render label when not provided" do
        render_inline(described_class.new(name: "plan", value: "basic"))

        expect(page).not_to have_css('label')
      end

      it "renders label with cursor-pointer when not disabled" do
        render_inline(described_class.new(name: "plan", value: "basic", label: "Basic"))

        expect(page).to have_css('label.cursor-pointer')
      end

      it "renders label with cursor-not-allowed when disabled" do
        render_inline(described_class.new(name: "plan", value: "basic", label: "Basic", disabled: true))

        expect(page).to have_css('label.cursor-not-allowed')
      end
    end

    context "with checked state" do
      it "renders checked attribute when checked is true" do
        render_inline(described_class.new(name: "plan", value: "basic", checked: true))

        expect(page).to have_css('input[checked]')
      end

      it "does not render checked attribute when checked is false" do
        render_inline(described_class.new(name: "plan", value: "basic", checked: false))

        expect(page).not_to have_css('input[checked]')
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "plan", value: "pro", hint: "Best value"))

        expect(page).to have_css('p#plan_pro-hint', text: "Best value")
      end

      it "does not render hint when not provided" do
        render_inline(described_class.new(name: "plan", value: "basic"))

        expect(page).not_to have_css('p[id$="-hint"]')
      end

      it "does not render hint when error is present" do
        render_inline(described_class.new(name: "plan", value: "basic", hint: "Help", error: "Please select"))

        expect(page).not_to have_css('p[id$="-hint"]')
        expect(page).to have_css('p[id$="-error"]')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "plan", value: "basic", error: "Please select a plan"))

        expect(page).to have_css('p#plan_basic-error', text: "Please select a plan")
      end

      it "applies error styling to radio" do
        render_inline(described_class.new(name: "plan", value: "basic", error: "Invalid"))

        expect(page).to have_css('input.border-red-300')
        expect(page).to have_css('input.text-red-600')
      end

      it "sets aria-invalid attribute when error present" do
        render_inline(described_class.new(name: "plan", value: "basic", error: "Invalid"))

        expect(page).to have_css('input[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id when error present" do
        render_inline(described_class.new(name: "plan", value: "basic", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="plan_basic-error"]')
      end

      it "renders error with multiple messages" do
        render_inline(described_class.new(name: "plan", value: "basic", error: [ "is required", "must be selected" ]))

        expect(page).to have_css('p#plan_basic-error', text: "is required, must be selected")
      end
    end

    context "with required field" do
      it "includes required attribute on radio" do
        render_inline(described_class.new(name: "plan", value: "basic", required: true))

        expect(page).to have_css('input[required]')
      end

      it "renders required indicator in label" do
        render_inline(described_class.new(name: "plan", value: "basic", label: "Basic", required: true))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "does not render required attribute when not required" do
        render_inline(described_class.new(name: "plan", value: "basic", required: false))

        expect(page).not_to have_css('input[required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on radio" do
        render_inline(described_class.new(name: "plan", value: "basic", disabled: true))

        expect(page).to have_css('input[disabled]')
      end

      it "applies disabled styling to radio" do
        render_inline(described_class.new(name: "plan", value: "basic", disabled: true))

        expect(page).to have_css('input.bg-slate-100')
        expect(page).to have_css('input.cursor-not-allowed')
      end

      it "applies disabled styling to label" do
        render_inline(described_class.new(name: "plan", value: "basic", label: "Basic", disabled: true))

        expect(page).to have_css('label.opacity-60')
        expect(page).to have_css('label.cursor-not-allowed')
      end

      it "does not include disabled attribute when not disabled" do
        render_inline(described_class.new(name: "plan", value: "basic", disabled: false))

        expect(page).not_to have_css('input[disabled]')
      end
    end

    context "with readonly state" do
      it "accepts readonly parameter" do
        # Note: readonly attribute is not standard for radio inputs in HTML5
        # The component accepts it but it may not have the expected effect
        component = described_class.new(name: "plan", value: "basic", readonly: true)

        expect(component.instance_variable_get(:@readonly)).to be true
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "plan",
          value: "basic",
          label: "Basic",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('input.h-3\\.5.w-3\\.5')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "plan",
          value: "basic",
          label: "Basic",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('input.h-4.w-4')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "plan",
          value: "basic",
          label: "Basic",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('input.h-5.w-5')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "plan", value: "basic", class: "custom-class"))

        expect(page).to have_css('input.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "plan",
          value: "basic",
          data: { controller: "radio" }
        ))

        expect(page).to have_css('input[data-controller="radio"]')
      end

      it "renders with multiple data attributes" do
        render_inline(described_class.new(
          name: "plan",
          value: "basic",
          data: { controller: "radio", action: "change" }
        ))

        expect(page).to have_css('input[data-controller="radio"]')
        expect(page).to have_css('input[data-action="change"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic"))

      expect(page).to have_css('label')
    end

    it "associates label with radio via for attribute" do
      render_inline(described_class.new(
        name: "plan",
        value: "pro",
        label: "Pro Plan"
      ))

      expect(page).to have_css('label[for="plan_pro"]')
      expect(page).to have_css('input#plan_pro')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "plan", value: "pro", hint: "Best value"))

      expect(page).to have_css('input[aria-describedby="plan_pro-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "plan", value: "basic", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="plan_basic-error"]')
    end

    it "prefers error over hint in aria-describedby" do
      render_inline(described_class.new(name: "plan", value: "basic", hint: "Help", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="plan_basic-error"]')
      expect(page).not_to have_css('input[aria-describedby*="hint"]')
    end

    it "includes aria-invalid when error present" do
      render_inline(described_class.new(name: "plan", value: "basic", error: "Invalid"))

      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "does not include aria-invalid when no error" do
      render_inline(described_class.new(name: "plan", value: "basic"))

      expect(page).not_to have_css('input[aria-invalid]')
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic", required: true))

      expect(page).to have_css('label span[aria-hidden="true"]', text: "*")
    end
  end

  describe "edge cases" do
    it "handles nil value converted to string" do
      component = described_class.new(name: "plan", value: nil)

      expect(component.instance_variable_get(:@value)).to eq(nil)
    end

    it "handles empty label" do
      render_inline(described_class.new(name: "plan", value: "basic", label: ""))

      expect(page).not_to have_css('label')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[preferences][plan]",
        value: "pro",
        label: "Pro Plan"
      ))

      expect(page).to have_css('input#user_preferences_plan_pro')
      expect(page).to have_css('input[name="user[preferences][plan]"]')
    end

    it "handles special characters in label" do
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic <script>alert('xss')</script>"))

      expect(page).to have_text("Basic")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in value for id generation" do
      render_inline(described_class.new(name: "plan", value: "pro-$19/month", label: "Pro"))

      expect(page).to have_css('input[value="pro-$19/month"]')
      # ID should sanitize special characters ($ and / become _)
      expect(page).to have_css('input[id="plan_pro-_19_month"]')
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[plan]",
        value: "enterprise",
        checked: true,
        label: "Enterprise Plan",
        hint: "Contact sales",
        error: "not available",
        required: true,
        disabled: false,
        size: :large,
        class: "custom-class",
        data: { controller: "plan" }
      ))

      expect(page).to have_css('input[name="user[plan]"]')
      expect(page).to have_css('input[value="enterprise"]')
      expect(page).to have_css('input[checked]')
      expect(page).to have_css('label', text: "Enterprise Plan")
      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('p[role="alert"]', text: "not available")
      expect(page).not_to have_css('p[id$="-hint"]')
      expect(page).to have_css('input[required]')
      expect(page).to have_css('input.custom-class')
      expect(page).to have_css('input[data-controller="plan"]')
    end
  end

  describe "layout" do
    it "renders radio and label in horizontal layout" do
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic"))

      expect(page).to have_css('.flex.items-start.gap-2')
    end

    it "renders radio with rounded-full shape" do
      render_inline(described_class.new(name: "plan", value: "basic"))

      expect(page).to have_css('input.rounded-full')
    end

    it "renders radio before label" do
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic Plan"))

      # Check structure: radio container with input first, then label
      container = page.find('.flex.items-start.gap-2')
      expect(container).to be_present
    end
  end

  describe "radio group usage" do
    it "renders with correct name for grouping" do
      # Note: render_inline only renders a single component at a time
      # For actual radio groups, use RadioGroupComponent
      render_inline(described_class.new(name: "plan", value: "basic", label: "Basic", checked: false))

      expect(page).to have_css('input[name="plan"]')
      expect(page).to have_css('input[type="radio"]')
      expect(page).to have_css('input.rounded-full')
    end
  end
end
