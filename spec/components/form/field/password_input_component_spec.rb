# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::PasswordInputComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "password")

      expect(component).to be_a(described_class)
    end

    it "accepts show_toggle parameter" do
      component = described_class.new(name: "password", show_toggle: false)

      expect(component.instance_variable_get(:@show_toggle)).to be false
    end

    it "defaults show_toggle to true" do
      component = described_class.new(name: "password")

      expect(component.instance_variable_get(:@show_toggle)).to be true
    end
  end

  describe "#show_toggle?" do
    it "returns true when show_toggle is true and not disabled" do
      component = described_class.new(name: "password", show_toggle: true, disabled: false)

      expect(component.show_toggle?).to be true
    end

    it "returns false when show_toggle is false" do
      component = described_class.new(name: "password", show_toggle: false)

      expect(component.show_toggle?).to be false
    end

    it "returns false when disabled" do
      component = described_class.new(name: "password", show_toggle: true, disabled: true)

      expect(component.show_toggle?).to be false
    end

    it "returns false when readonly" do
      component = described_class.new(name: "password", show_toggle: true, readonly: true)

      expect(component.show_toggle?).to be false
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders password input with type password" do
        render_inline(described_class.new(name: "password"))

        expect(page).to have_css('input[type="password"]')
      end

      it "renders password input with name attribute" do
        render_inline(described_class.new(name: "password"))

        expect(page).to have_css('input[name="password"]')
      end

      it "renders password input with generated id" do
        render_inline(described_class.new(name: "user[password]"))

        expect(page).to have_css('input#user_password')
      end

      it "renders password input with custom id" do
        render_inline(described_class.new(name: "password", id: "custom_password"))

        expect(page).to have_css('input#custom_password')
      end

      it "renders password input with value" do
        render_inline(described_class.new(name: "password", value: "secret123"))

        expect(page).to have_css('input[value="secret123"]')
      end
    end

    context "with label" do
      it "renders label when provided" do
        render_inline(described_class.new(name: "password", label: "Password"))

        expect(page).to have_css('label', text: "Password")
      end

      it "associates label with input via for attribute" do
        render_inline(described_class.new(name: "password", id: "pass", label: "Password"))

        expect(page).to have_css('label[for="pass"]')
        expect(page).to have_css('input#pass')
      end

      it "does not render label when not provided" do
        render_inline(described_class.new(name: "password"))

        expect(page).not_to have_css('label')
      end
    end

    context "with placeholder" do
      it "renders placeholder when provided" do
        render_inline(described_class.new(name: "password", placeholder: "Enter password"))

        expect(page).to have_css('input[placeholder="Enter password"]')
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "password", hint: "Must be at least 8 characters"))

        expect(page).to have_css('p#password-hint', text: "Must be at least 8 characters")
      end

      it "does not render hint when not provided" do
        render_inline(described_class.new(name: "password"))

        expect(page).not_to have_css('p#password-hint')
      end

      it "does not render hint when error is present" do
        render_inline(described_class.new(name: "password", hint: "Help", error: "is too short"))

        expect(page).not_to have_css('p#password-hint')
        expect(page).to have_css('p#password-error')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "password", error: "is too short"))

        expect(page).to have_css('p#password-error', text: "is too short")
      end

      it "applies error styling to input" do
        render_inline(described_class.new(name: "password", error: "Invalid"))

        expect(page).to have_css('input.border-red-400')
        expect(page).to have_css('input.bg-red-50\\/50')
      end

      it "sets aria-invalid attribute when error present" do
        render_inline(described_class.new(name: "password", error: "Invalid"))

        expect(page).to have_css('input[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id when error present" do
        render_inline(described_class.new(name: "password", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="password-error"]')
      end

      it "renders error with multiple messages" do
        render_inline(described_class.new(name: "password", error: [ "is too short", "is weak" ]))

        expect(page).to have_css('p#password-error', text: "is too short, is weak")
      end
    end

    context "with required field" do
      it "includes required attribute on input" do
        render_inline(described_class.new(name: "password", required: true))

        expect(page).to have_css('input[required]')
      end

      it "renders required indicator in label" do
        render_inline(described_class.new(name: "password", label: "Password", required: true))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "does not render required attribute when not required" do
        render_inline(described_class.new(name: "password", required: false))

        expect(page).not_to have_css('input[required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on input" do
        render_inline(described_class.new(name: "password", disabled: true))

        expect(page).to have_css('input[disabled]')
      end

      it "applies disabled styling to input" do
        render_inline(described_class.new(name: "password", disabled: true))

        expect(page).to have_css('input.bg-slate-100')
        expect(page).to have_css('input.cursor-not-allowed')
      end

      it "does not include disabled attribute when not disabled" do
        render_inline(described_class.new(name: "password", disabled: false))

        expect(page).not_to have_css('input[disabled]')
      end
    end

    context "with readonly state" do
      it "includes readonly attribute on input" do
        render_inline(described_class.new(name: "password", readonly: true))

        expect(page).to have_css('input[readonly]')
      end

      it "does not include readonly attribute when not readonly" do
        render_inline(described_class.new(name: "password", readonly: false))

        expect(page).not_to have_css('input[readonly]')
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "password",
          label: "Password",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('input.px-3.py-2.text-xs')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "password",
          label: "Password",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('input.px-3\\.5.py-2\\.5.text-sm')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "password",
          label: "Password",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('input.px-4.py-3.text-base')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "password", class: "custom-class"))

        expect(page).to have_css('input.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "password",
          data: { controller: "password-strength" }
        ))

        expect(page).to have_css('input[data-controller="password-strength"]')
      end

      it "renders with autocomplete attribute for new password" do
        render_inline(described_class.new(
          name: "password",
          autocomplete: "new-password"
        ))

        expect(page).to have_css('input[autocomplete="new-password"]')
      end

      it "renders with autocomplete attribute for current password" do
        render_inline(described_class.new(
          name: "password",
          autocomplete: "current-password"
        ))

        expect(page).to have_css('input[autocomplete="current-password"]')
      end

      it "renders with autocomplete attribute for password confirmation" do
        render_inline(described_class.new(
          name: "password_confirmation",
          autocomplete: "new-password"
        ))

        expect(page).to have_css('input[autocomplete="new-password"]')
      end
    end
  end

  describe "visibility toggle" do
    context "when show_toggle is true" do
      it "includes Stimulus controller on wrapper" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('[data-controller="components--password-input"]')
      end

      it "renders toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('button[type="button"]')
      end

      it "includes Stimulus target on input" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('input[data-components--password-input-target="input"]')
      end

      it "includes Stimulus action on toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('button[data-action="click->components--password-input#toggle"]')
      end

      it "includes target on toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('button[data-components--password-input-target="toggleButton"]')
      end

      it "includes aria-label on toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('button[aria-label="Basculer la visibilité du mot de passe"]')
      end

      it "includes I18n data attributes for toggle labels" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('button[data-show-label="Afficher le mot de passe"]')
        expect(page).to have_css('button[data-hide-label="Masquer le mot de passe"]')
      end

      it "renders eye icon (show icon)" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('span[data-components--password-input-target="showIcon"]')
      end

      it "renders eye-slash icon (hide icon) with hidden class" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('span[data-components--password-input-target="hideIcon"].hidden')
      end

      it "adds right padding to input for toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: true))

        expect(page).to have_css('input.pr-10')
      end
    end

    context "when show_toggle is false" do
      it "does not include Stimulus controller" do
        render_inline(described_class.new(name: "password", show_toggle: false))

        expect(page).not_to have_css('[data-controller="components--password-input"]')
      end

      it "does not render toggle button" do
        render_inline(described_class.new(name: "password", show_toggle: false))

        expect(page).not_to have_css('button')
      end

      it "does not include Stimulus target on input" do
        render_inline(described_class.new(name: "password", show_toggle: false))

        expect(page).not_to have_css('input[data-components--password-input-target="input"]')
      end

      it "does not add right padding to input" do
        render_inline(described_class.new(name: "password", show_toggle: false))

        expect(page).not_to have_css('input.pr-10')
      end
    end

    context "when disabled" do
      it "does not show toggle button even if show_toggle is true" do
        render_inline(described_class.new(name: "password", show_toggle: true, disabled: true))

        expect(page).not_to have_css('button')
        expect(page).not_to have_css('[data-controller="components--password-input"]')
      end
    end

    context "when readonly" do
      it "does not show toggle button even if show_toggle is true" do
        render_inline(described_class.new(name: "password", show_toggle: true, readonly: true))

        expect(page).not_to have_css('button')
        expect(page).not_to have_css('[data-controller="components--password-input"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "password", label: "Password"))

      expect(page).to have_css('label')
    end

    it "associates label with input via for attribute" do
      render_inline(described_class.new(
        name: "password",
        id: "user_password",
        label: "Password"
      ))

      expect(page).to have_css('label[for="user_password"]')
      expect(page).to have_css('input#user_password')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "password", hint: "At least 8 characters"))

      expect(page).to have_css('input[aria-describedby="password-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "password", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="password-error"]')
    end

    it "prefers error over hint in aria-describedby" do
      render_inline(described_class.new(name: "password", hint: "Help", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="password-error"]')
      expect(page).not_to have_css('input[aria-describedby*="hint"]')
    end

    it "includes aria-invalid when error present" do
      render_inline(described_class.new(name: "password", error: "Invalid"))

      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "does not include aria-invalid when no error" do
      render_inline(described_class.new(name: "password"))

      expect(page).not_to have_css('input[aria-invalid]')
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(name: "password", label: "Password", required: true))

      expect(page).to have_css('label span[aria-hidden="true"]', text: "*")
    end

    it "error has role alert" do
      render_inline(described_class.new(name: "password", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "toggle button has aria-label" do
      render_inline(described_class.new(name: "password", show_toggle: true))

      expect(page).to have_css('button[aria-label="Basculer la visibilité du mot de passe"]')
    end
  end

  describe "edge cases" do
    it "handles nil value" do
      render_inline(described_class.new(name: "password", value: nil))

      expect(page).to have_css('input[type="password"]')
    end

    it "handles empty label" do
      render_inline(described_class.new(name: "password", label: ""))

      expect(page).not_to have_css('label')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[credentials][password]",
        label: "Password"
      ))

      expect(page).to have_css('input#user_credentials_password')
      expect(page).to have_css('input[name="user[credentials][password]"]')
    end

    it "handles special characters in label" do
      render_inline(described_class.new(name: "password", label: "Password <script>alert('xss')</script>"))

      expect(page).to have_text("Password")
      expect(page).not_to have_css("script")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[password]",
        id: "custom_pass",
        value: "secret",
        label: "Password",
        placeholder: "Enter password",
        hint: "At least 8 characters",
        error: "is too short",
        required: true,
        disabled: false,
        size: :large,
        show_toggle: true,
        class: "custom-class",
        data: { test: "value" }
      ))

      expect(page).to have_css('input#custom_pass')
      expect(page).to have_css('input[name="user[password]"]')
      expect(page).to have_css('input[type="password"]')
      expect(page).to have_css('input[value="secret"]')
      expect(page).to have_css('input[placeholder="Enter password"]')
      expect(page).to have_css('label', text: "Password")
      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('p#custom_pass-error', text: "is too short")
      expect(page).not_to have_css('p#custom_pass-hint')
      expect(page).to have_css('input[required]')
      expect(page).to have_css('input.custom-class')
      expect(page).to have_css('input[data-test="value"]')
      expect(page).to have_css('button[aria-label="Basculer la visibilité du mot de passe"]')
    end
  end
end
