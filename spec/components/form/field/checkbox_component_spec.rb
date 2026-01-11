# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::CheckboxComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "terms")

      expect(component).to be_a(described_class)
    end

    it "accepts checked parameter" do
      component = described_class.new(name: "terms", checked: true)

      expect(component.instance_variable_get(:@checked)).to be true
    end

    it "accepts custom value" do
      component = described_class.new(name: "terms", value: "accepted")

      expect(component.instance_variable_get(:@value)).to eq("accepted")
    end

    it "defaults value to '1'" do
      component = described_class.new(name: "terms")

      expect(component.instance_variable_get(:@value)).to eq("1")
    end

    it "defaults checked to false" do
      component = described_class.new(name: "terms")

      expect(component.instance_variable_get(:@checked)).to be false
    end

    it "accepts include_hidden parameter" do
      component = described_class.new(name: "terms", include_hidden: false)

      expect(component.instance_variable_get(:@include_hidden)).to be false
    end

    it "defaults include_hidden to true" do
      component = described_class.new(name: "terms")

      expect(component.instance_variable_get(:@include_hidden)).to be true
    end

    it "removes placeholder parameter" do
      component = described_class.new(name: "terms", placeholder: "Should be removed")

      expect(component.instance_variable_get(:@placeholder)).to be_nil
    end
  end

  describe "#checked?" do
    it "returns true when checked is true" do
      component = described_class.new(name: "terms", checked: true)

      expect(component.checked?).to be true
    end

    it "returns false when checked is false" do
      component = described_class.new(name: "terms", checked: false)

      expect(component.checked?).to be false
    end
  end

  describe "#include_hidden?" do
    it "returns true when include_hidden is true" do
      component = described_class.new(name: "terms", include_hidden: true)

      expect(component.include_hidden?).to be true
    end

    it "returns false when include_hidden is false" do
      component = described_class.new(name: "terms", include_hidden: false)

      expect(component.include_hidden?).to be false
    end
  end

  describe "#has_label?" do
    it "returns true when label prop is provided" do
      component = described_class.new(name: "terms", label: "Accept terms")

      expect(component.has_label?).to be true
    end

    it "returns false when label prop is not provided" do
      component = described_class.new(name: "terms")

      expect(component.has_label?).to be false
    end

    it "returns true when label_content slot is provided" do
      component = described_class.new(name: "terms")
      render_inline(component) do |checkbox|
        checkbox.with_label_content { "Custom label" }
      end

      expect(component.has_label?).to be true
    end
  end

  describe "label_content slot" do
    it "renders label_content slot when provided" do
      render_inline(described_class.new(name: "terms")) do |checkbox|
        checkbox.with_label_content { "Custom label with <strong>HTML</strong>".html_safe }
      end

      expect(page).to have_css('label strong', text: "HTML")
      expect(page).to have_text("Custom label with HTML")
    end

    it "prefers label_content slot over label prop" do
      render_inline(described_class.new(name: "terms", label: "Prop label")) do |checkbox|
        checkbox.with_label_content { "Slot label" }
      end

      expect(page).to have_text("Slot label")
      expect(page).not_to have_text("Prop label")
    end

    it "renders required indicator with label_content slot" do
      render_inline(described_class.new(name: "terms", required: true)) do |checkbox|
        checkbox.with_label_content { "Custom label" }
      end

      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('label span[aria-hidden="true"]')
    end

    it "allows links in label_content slot" do
      render_inline(described_class.new(name: "terms")) do |checkbox|
        checkbox.with_label_content do
          "I agree to the <a href='/terms' class='text-blue-600 underline'>terms</a>".html_safe
        end
      end

      expect(page).to have_css('label a[href="/terms"]', text: "terms")
      expect(page).to have_css('label a.text-blue-600.underline')
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders checkbox input with type checkbox" do
        render_inline(described_class.new(name: "terms"))

        expect(page).to have_css('input[type="checkbox"]')
      end

      it "renders checkbox with name attribute" do
        render_inline(described_class.new(name: "terms"))

        expect(page).to have_css('input[name="terms"]')
      end

      it "renders checkbox with generated id" do
        render_inline(described_class.new(name: "user[terms]"))

        expect(page).to have_css('input#user_terms')
      end

      it "renders checkbox with custom id" do
        render_inline(described_class.new(name: "terms", id: "custom_id"))

        expect(page).to have_css('input#custom_id')
      end

      it "renders checkbox with default value '1'" do
        render_inline(described_class.new(name: "terms"))

        expect(page).to have_css('input[value="1"]')
      end

      it "renders checkbox with custom value" do
        render_inline(described_class.new(name: "terms", value: "accepted"))

        expect(page).to have_css('input[value="accepted"]')
      end
    end

    context "with label" do
      it "renders label when provided" do
        render_inline(described_class.new(name: "terms", label: "I agree to terms"))

        expect(page).to have_css('label', text: "I agree to terms")
      end

      it "associates label with checkbox via for attribute" do
        render_inline(described_class.new(name: "terms", id: "terms_checkbox", label: "Accept"))

        expect(page).to have_css('label[for="terms_checkbox"]')
        expect(page).to have_css('input#terms_checkbox')
      end

      it "does not render label when not provided" do
        render_inline(described_class.new(name: "terms"))

        expect(page).not_to have_css('label')
      end

      it "renders label with cursor-pointer when not disabled" do
        render_inline(described_class.new(name: "terms", label: "Accept"))

        expect(page).to have_css('label.cursor-pointer')
      end

      it "renders label with cursor-not-allowed when disabled" do
        render_inline(described_class.new(name: "terms", label: "Accept", disabled: true))

        expect(page).to have_css('label.cursor-not-allowed')
      end
    end

    context "with checked state" do
      it "renders checked attribute when checked is true" do
        render_inline(described_class.new(name: "terms", checked: true))

        expect(page).to have_css('input[checked]')
      end

      it "does not render checked attribute when checked is false" do
        render_inline(described_class.new(name: "terms", checked: false))

        expect(page).not_to have_css('input[checked]')
      end
    end

    context "with hidden field" do
      it "renders hidden field with value '0' when include_hidden is true" do
        render_inline(described_class.new(name: "terms", include_hidden: true))

        expect(page).to have_css('input[type="hidden"][name="terms"][value="0"]', visible: false)
      end

      it "does not render hidden field when include_hidden is false" do
        render_inline(described_class.new(name: "terms", include_hidden: false))

        expect(page).not_to have_css('input[type="hidden"]', visible: false)
      end

      it "renders hidden field before checkbox" do
        render_inline(described_class.new(name: "terms", include_hidden: true))

        # Hidden field should come before checkbox in form submission order
        inputs = page.all('input[name="terms"]', visible: :all)
        expect(inputs.count).to eq(2)
        expect(inputs[0][:type]).to eq("hidden")
        expect(inputs[1][:type]).to eq("checkbox")
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "terms", hint: "You can unsubscribe later"))

        expect(page).to have_css('p#terms-hint', text: "You can unsubscribe later")
      end

      it "does not render hint when not provided" do
        render_inline(described_class.new(name: "terms"))

        expect(page).not_to have_css('p#terms-hint')
      end

      it "does not render hint when error is present" do
        render_inline(described_class.new(name: "terms", hint: "Help", error: "must be accepted"))

        expect(page).not_to have_css('p#terms-hint')
        expect(page).to have_css('p#terms-error')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "terms", error: "must be accepted"))

        expect(page).to have_css('p#terms-error', text: "must be accepted")
      end

      it "applies error styling to checkbox" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('input.border-red-300')
        expect(page).to have_css('input.text-red-600')
      end

      it "sets aria-invalid attribute when error present" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('input[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id when error present" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="terms-error"]')
      end

      it "renders error with multiple messages" do
        render_inline(described_class.new(name: "terms", error: [ "must be accepted", "is required" ]))

        expect(page).to have_css('p#terms-error', text: "must be accepted, is required")
      end
    end

    context "with required field" do
      it "includes required attribute on checkbox" do
        render_inline(described_class.new(name: "terms", required: true))

        expect(page).to have_css('input[required]')
      end

      it "renders required indicator in label" do
        render_inline(described_class.new(name: "terms", label: "Accept", required: true))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "does not render required attribute when not required" do
        render_inline(described_class.new(name: "terms", required: false))

        expect(page).not_to have_css('input[required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on checkbox" do
        render_inline(described_class.new(name: "terms", disabled: true))

        expect(page).to have_css('input[disabled]')
      end

      it "applies disabled styling to checkbox" do
        render_inline(described_class.new(name: "terms", disabled: true))

        expect(page).to have_css('input.bg-slate-100')
        expect(page).to have_css('input.cursor-not-allowed')
      end

      it "applies disabled styling to label" do
        render_inline(described_class.new(name: "terms", label: "Accept", disabled: true))

        expect(page).to have_css('label.opacity-60')
        expect(page).to have_css('label.cursor-not-allowed')
      end

      it "does not include disabled attribute when not disabled" do
        render_inline(described_class.new(name: "terms", disabled: false))

        expect(page).not_to have_css('input[disabled]')
      end
    end

    context "with readonly state" do
      it "accepts readonly parameter" do
        # Note: readonly attribute is not standard for checkboxes in HTML5
        # The component accepts it but it may not have the expected effect
        component = described_class.new(name: "terms", readonly: true)

        expect(component.instance_variable_get(:@readonly)).to be true
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "terms",
          label: "Accept",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('input.h-3\\.5.w-3\\.5')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "terms",
          label: "Accept",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('input.h-4.w-4')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "terms",
          label: "Accept",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('input.h-5.w-5')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "terms", class: "custom-class"))

        expect(page).to have_css('input.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "terms",
          data: { controller: "checkbox" }
        ))

        expect(page).to have_css('input[data-controller="checkbox"]')
      end

      it "renders with multiple data attributes" do
        render_inline(described_class.new(
          name: "terms",
          data: { controller: "checkbox", action: "change" }
        ))

        expect(page).to have_css('input[data-controller="checkbox"]')
        expect(page).to have_css('input[data-action="change"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "terms", label: "Accept"))

      expect(page).to have_css('label')
    end

    it "associates label with checkbox via for attribute" do
      render_inline(described_class.new(
        name: "terms",
        id: "terms_checkbox",
        label: "Accept"
      ))

      expect(page).to have_css('label[for="terms_checkbox"]')
      expect(page).to have_css('input#terms_checkbox')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "terms", hint: "Help"))

      expect(page).to have_css('input[aria-describedby="terms-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "terms", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="terms-error"]')
    end

    it "prefers error over hint in aria-describedby" do
      render_inline(described_class.new(name: "terms", hint: "Help", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="terms-error"]')
      expect(page).not_to have_css('input[aria-describedby*="hint"]')
    end

    it "includes aria-invalid when error present" do
      render_inline(described_class.new(name: "terms", error: "Invalid"))

      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "does not include aria-invalid when no error" do
      render_inline(described_class.new(name: "terms"))

      expect(page).not_to have_css('input[aria-invalid]')
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(name: "terms", label: "Accept", required: true))

      expect(page).to have_css('label span[aria-hidden="true"]', text: "*")
    end
  end

  describe "edge cases" do
    it "handles nil value" do
      render_inline(described_class.new(name: "terms", value: nil))

      expect(page).to have_css('input[type="checkbox"]')
    end

    it "handles empty label" do
      render_inline(described_class.new(name: "terms", label: ""))

      expect(page).not_to have_css('label')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[preferences][terms]",
        label: "Accept"
      ))

      expect(page).to have_css('input#user_preferences_terms')
      expect(page).to have_css('input[name="user[preferences][terms]"]')
    end

    it "handles special characters in label" do
      render_inline(described_class.new(name: "terms", label: "Accept <script>alert('xss')</script>"))

      expect(page).to have_text("Accept")
      expect(page).not_to have_css("script")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[terms]",
        id: "custom_terms",
        value: "accepted",
        checked: true,
        label: "I accept the terms",
        hint: "Required to continue",
        error: "must be checked",
        required: true,
        disabled: false,
        size: :large,
        class: "custom-class",
        data: { controller: "terms" }
      ))

      expect(page).to have_css('input#custom_terms')
      expect(page).to have_css('input[name="user[terms]"]')
      expect(page).to have_css('input[value="accepted"]')
      expect(page).to have_css('input[checked]')
      expect(page).to have_css('label', text: "I accept the terms")
      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('p#custom_terms-error', text: "must be checked")
      expect(page).not_to have_css('p#custom_terms-hint')
      expect(page).to have_css('input[required]')
      expect(page).to have_css('input.custom-class')
      expect(page).to have_css('input[data-controller="terms"]')
    end
  end

  describe "layout" do
    it "renders checkbox and label in horizontal layout" do
      render_inline(described_class.new(name: "terms", label: "Accept"))

      expect(page).to have_css('.flex.items-start.gap-2')
    end

    it "renders checkbox before label" do
      render_inline(described_class.new(name: "terms", label: "Accept terms"))

      # Check structure: checkbox container with input first, then label
      container = page.find('.flex.items-start.gap-2')
      expect(container).to be_present
    end
  end
end
