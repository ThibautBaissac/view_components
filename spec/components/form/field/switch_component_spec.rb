# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::SwitchComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "notifications")

      expect(component).to be_a(described_class)
    end

    it "accepts value parameter" do
      component = described_class.new(name: "feature", value: "enabled")

      expect(component.instance_variable_get(:@value)).to eq("enabled")
    end

    it "accepts checked parameter" do
      component = described_class.new(name: "notifications", checked: true)

      expect(component.instance_variable_get(:@checked)).to eq(true)
    end

    it "accepts include_hidden parameter" do
      component = described_class.new(name: "notifications", include_hidden: false)

      expect(component.instance_variable_get(:@include_hidden)).to eq(false)
    end

    it "defaults value to '1'" do
      component = described_class.new(name: "notifications")

      expect(component.instance_variable_get(:@value)).to eq("1")
    end

    it "defaults checked to false" do
      component = described_class.new(name: "notifications")

      expect(component.instance_variable_get(:@checked)).to eq(false)
    end

    it "defaults include_hidden to true" do
      component = described_class.new(name: "notifications")

      expect(component.instance_variable_get(:@include_hidden)).to eq(true)
    end

    it "removes placeholder from options" do
      component = described_class.new(name: "notifications", placeholder: "ignored")

      expect(component.instance_variable_get(:@placeholder)).to be_nil
    end

    it "ignores readonly from options (not applicable to switches)" do
      component = described_class.new(name: "notifications", readonly: true)

      # readonly is deleted from options hash, so BaseComponent sets the default (false)
      expect(component.instance_variable_get(:@readonly)).to eq(false)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders wrapper div with form-field class" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css("div.form-field")
      end

      it "renders checkbox input with switch role" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('input[type="checkbox"][role="switch"]')
      end

      it "renders input with name attribute" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('input[name="notifications"]')
      end

      it "renders input with generated id" do
        render_inline(described_class.new(name: "user[notifications]"))

        expect(page).to have_css("input#user_notifications")
      end

      it "renders input with custom id" do
        render_inline(described_class.new(name: "notifications", id: "custom_id"))

        expect(page).to have_css("input#custom_id")
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "notifications", label: "Enable notifications"))

        expect(page).to have_css('label[for="notifications"]', text: "Enable notifications")
      end

      it "renders hint when provided" do
        render_inline(described_class.new(name: "notifications", hint: "Receive updates"))

        expect(page).to have_css('p#notifications-hint', text: "Receive updates")
      end

      it "renders error when provided" do
        render_inline(described_class.new(name: "terms", error: "must be accepted"))

        expect(page).to have_css('p#terms-error[role="alert"]', text: "must be accepted")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(name: "terms", hint: "Required", error: "Invalid"))

        expect(page).to have_css('p#terms-error')
        expect(page).not_to have_css('p#terms-hint')
      end
    end

    context "with hidden field" do
      it "renders hidden field when include_hidden is true" do
        render_inline(described_class.new(name: "notifications", include_hidden: true))

        expect(page).to have_css('input[type="hidden"][name="notifications"][value="0"]', visible: :all)
      end

      it "does not render hidden field when include_hidden is false" do
        render_inline(described_class.new(name: "notifications", include_hidden: false))

        expect(page).not_to have_css('input[type="hidden"]', visible: :all)
      end

      it "renders hidden field before checkbox" do
        html = render_inline(described_class.new(name: "notifications")).to_html
        hidden_pos = html.index('type="hidden"')
        checkbox_pos = html.index('type="checkbox"')

        expect(hidden_pos).to be < checkbox_pos
      end
    end

    context "with checked state" do
      it "renders checked attribute when checked is true" do
        render_inline(described_class.new(name: "notifications", checked: true))

        expect(page).to have_css('input[type="checkbox"][checked]')
      end

      it "does not render checked attribute when checked is false" do
        render_inline(described_class.new(name: "notifications", checked: false))

        expect(page).not_to have_css('input[type="checkbox"][checked]')
      end

      it "renders aria-checked=true when checked" do
        render_inline(described_class.new(name: "notifications", checked: true))

        expect(page).to have_css('input[aria-checked="true"]')
      end

      it "renders aria-checked=false when unchecked" do
        render_inline(described_class.new(name: "notifications", checked: false))

        expect(page).to have_css('input[aria-checked="false"]')
      end
    end

    context "with custom value" do
      it "renders value attribute" do
        render_inline(described_class.new(name: "feature", value: "enabled"))

        expect(page).to have_css('input[type="checkbox"][value="enabled"]')
      end

      it "uses default value when not specified" do
        render_inline(described_class.new(name: "feature"))

        expect(page).to have_css('input[type="checkbox"][value="1"]')
      end
    end

    context "with switch track and knob" do
      it "renders switch track element" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('span[aria-hidden="true"].rounded-full')
      end

      it "renders switch knob element" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css("span.bg-white.rounded-full.-translate-y-1\\/2")
      end

      it "applies transition classes to track" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('span[aria-hidden="true"].transition-colors')
      end

      it "applies transition classes to knob" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css("span.transition.duration-200")
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(
          name: "terms",
          label: "Accept terms",
          required: true
        ))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on input" do
        render_inline(described_class.new(name: "terms", required: true))

        expect(page).to have_css('input[type="checkbox"][required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on input" do
        render_inline(described_class.new(name: "notifications", disabled: true))

        expect(page).to have_css('input[type="checkbox"][disabled]')
      end

      it "applies disabled styling to track when unchecked" do
        render_inline(described_class.new(name: "notifications", disabled: true, checked: false))

        expect(page).to have_css('span[aria-hidden="true"].bg-slate-200.cursor-not-allowed')
      end

      it "applies disabled styling to track when checked" do
        render_inline(described_class.new(name: "notifications", disabled: true, checked: true))

        expect(page).to have_css('span[aria-hidden="true"].bg-blue-300.cursor-not-allowed')
      end

      it "applies disabled styling to label" do
        render_inline(described_class.new(name: "notifications", label: "Test", disabled: true))

        expect(page).to have_css("label.cursor-not-allowed.opacity-60")
      end
    end

    context "with error state" do
      it "applies error styling to track" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('span[aria-hidden="true"].bg-red-200')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('input[type="checkbox"][aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "terms", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="terms-error"]')
      end
    end

    context "with different sizes" do
      it "applies small size classes to track" do
        render_inline(described_class.new(name: "notifications", size: :small))

        expect(page).to have_css('span[aria-hidden="true"].h-5.w-9')
      end

      it "applies medium size classes to track" do
        render_inline(described_class.new(name: "notifications", size: :medium))

        expect(page).to have_css('span[aria-hidden="true"].h-6.w-11')
      end

      it "applies large size classes to track" do
        render_inline(described_class.new(name: "notifications", size: :large))

        expect(page).to have_css('span[aria-hidden="true"].h-7.w-14')
      end

      it "applies small size classes to knob" do
        render_inline(described_class.new(name: "notifications", size: :small))

        expect(page).to have_css("span.bg-white.h-4.w-4")
      end

      it "applies medium size classes to knob" do
        render_inline(described_class.new(name: "notifications", size: :medium))

        expect(page).to have_css("span.bg-white.h-5.w-5")
      end

      it "applies large size classes to knob" do
        render_inline(described_class.new(name: "notifications", size: :large))

        expect(page).to have_css("span.bg-white.h-6.w-6")
      end

      it "applies small size classes to label" do
        render_inline(described_class.new(name: "notifications", label: "Test", size: :small))

        expect(page).to have_css("label.text-xs")
      end

      it "applies medium size classes to label" do
        render_inline(described_class.new(name: "notifications", label: "Test", size: :medium))

        expect(page).to have_css("label.text-sm")
      end

      it "applies large size classes to label" do
        render_inline(described_class.new(name: "notifications", label: "Test", size: :large))

        expect(page).to have_css("label.text-base")
      end
    end

    context "with label slot" do
      it "renders label_content slot when provided" do
        render_inline(described_class.new(name: "terms")) do |component|
          component.with_label_content do
            "I agree to the <a href='/terms'>terms</a>".html_safe
          end
        end

        expect(page).to have_css("label a[href='/terms']", text: "terms")
      end

      it "prefers label_content slot over label prop" do
        render_inline(described_class.new(name: "terms", label: "Prop Label")) do |component|
          component.with_label_content do
            "Slot Label"
          end
        end

        expect(page).to have_css("label", text: "Slot Label")
        expect(page).not_to have_content("Prop Label")
      end

      it "has_label? returns true when label_content slot is provided" do
        component = described_class.new(name: "terms")
        render_inline(component) do |c|
          c.with_label_content { "Label" }
        end

        expect(page).to have_css("label")
      end
    end

    context "with focus styles" do
      it "renders focus ring classes on track" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('span[aria-hidden="true"].focus-visible\\:ring-2')
      end

      it "renders focus ring offset classes on track" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('span[aria-hidden="true"].focus-visible\\:ring-offset-2')
      end
    end

    context "with peer classes for CSS state" do
      it "hides input with sr-only and peer class" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css("input.sr-only.peer")
      end

      it "applies peer-checked classes to track" do
        render_inline(described_class.new(name: "notifications"))

        expect(page).to have_css('span[aria-hidden="true"].peer-checked\\:bg-blue-600')
      end

      it "applies peer-checked translation to knob" do
        render_inline(described_class.new(name: "notifications", size: :medium))

        expect(page).to have_css("span.peer-checked\\:translate-x-\\[18px\\]")
      end
    end
  end

  describe "accessibility" do
    it "uses role=switch for ARIA compliance" do
      render_inline(described_class.new(name: "notifications"))

      expect(page).to have_css('input[role="switch"]')
    end

    it "associates label with input via for attribute" do
      render_inline(described_class.new(
        name: "notifications",
        id: "notify_switch",
        label: "Notifications"
      ))

      expect(page).to have_css('label[for="notify_switch"]')
      expect(page).to have_css("input#notify_switch")
    end

    it "has two labels for track and text (both clickable)" do
      render_inline(described_class.new(name: "notifications", label: "Test"))

      # One label wraps the track, one is for the text
      expect(page).to have_css('label[for="notifications"]', count: 2)
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "notifications", hint: "Help"))

      expect(page).to have_css('input[aria-describedby="notifications-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "terms", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="terms-error"]')
    end

    it "includes aria-checked attribute" do
      render_inline(described_class.new(name: "notifications", checked: true))

      expect(page).to have_css('input[aria-checked="true"]')
    end

    it "includes aria-required when required" do
      render_inline(described_class.new(name: "terms", label: "Terms", required: true))

      expect(page).to have_css('input[aria-required="true"]')
    end

    it "does not include aria-required when not required" do
      render_inline(described_class.new(name: "terms", label: "Terms", required: false))

      expect(page).not_to have_css('input[aria-required]')
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "terms", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "hides decorative track from assistive technology" do
      render_inline(described_class.new(name: "notifications"))

      expect(page).to have_css('span[aria-hidden="true"]')
    end
  end

  describe "edge cases" do
    it "handles nil label" do
      render_inline(described_class.new(name: "notifications", label: nil))

      expect(page).to have_css('input[type="checkbox"][role="switch"]')
      # Only the track label should exist, not the text label
      expect(page).to have_css('label[for="notifications"]', count: 1)
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[preferences][notifications]",
        label: "Notifications"
      ))

      expect(page).to have_css('input[name="user[preferences][notifications]"]')
      expect(page).to have_css("input#user_preferences_notifications")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[terms]",
        value: "accepted",
        checked: true,
        label: "Terms",
        hint: "Accept to continue",
        error: "must accept",
        required: true,
        disabled: true,
        size: :large,
        include_hidden: true
      ))

      expect(page).to have_css('input[name="user[terms]"]')
      expect(page).to have_css('input[value="accepted"]')
      expect(page).to have_css("input[checked]")
      expect(page).to have_css("label", text: "Terms")
      expect(page).to have_css("label span.text-red-500", text: "*")
      expect(page).to have_css('p[role="alert"]', text: "must accept")
      expect(page).to have_css("input[disabled]")
      expect(page).to have_css('input[type="hidden"][value="0"]', visible: :all)
    end

    it "handles empty label string" do
      render_inline(described_class.new(name: "notifications", label: ""))

      # Empty string means has_label? returns false
      expect(page).to have_css('label[for="notifications"]', count: 1)
    end
  end

  describe "#checked?" do
    it "returns true when checked is true" do
      component = described_class.new(name: "notifications", checked: true)

      expect(component.checked?).to eq(true)
    end

    it "returns false when checked is false" do
      component = described_class.new(name: "notifications", checked: false)

      expect(component.checked?).to eq(false)
    end
  end

  describe "#include_hidden?" do
    it "returns true when include_hidden is true" do
      component = described_class.new(name: "notifications", include_hidden: true)

      expect(component.include_hidden?).to eq(true)
    end

    it "returns false when include_hidden is false" do
      component = described_class.new(name: "notifications", include_hidden: false)

      expect(component.include_hidden?).to eq(false)
    end
  end

  describe "#has_label?" do
    it "returns true when label is present" do
      component = described_class.new(name: "notifications", label: "Test")

      expect(component.has_label?).to eq(true)
    end

    it "returns false when label is nil" do
      component = described_class.new(name: "notifications", label: nil)

      expect(component.has_label?).to eq(false)
    end

    it "returns false when label is empty string" do
      component = described_class.new(name: "notifications", label: "")

      expect(component.has_label?).to eq(false)
    end

    it "returns true when label_content slot is provided" do
      component = described_class.new(name: "notifications")
      render_inline(component) do |c|
        c.with_label_content { "Slot Content" }
      end

      # After rendering, has_label? should be true due to slot
      expect(page).to have_css('label[for="notifications"]', text: "Slot Content")
    end
  end
end
