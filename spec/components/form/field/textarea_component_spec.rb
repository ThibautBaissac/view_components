# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::TextareaComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "description")

      expect(component).to be_a(described_class)
    end

    it "uses default rows when not specified" do
      component = described_class.new(name: "description")

      expect(component.instance_variable_get(:@rows)).to eq(Form::Field::TextareaComponent::DEFAULT_ROWS)
    end

    it "accepts custom rows" do
      component = described_class.new(name: "description", rows: 10)

      expect(component.instance_variable_get(:@rows)).to eq(10)
    end

    it "accepts cols parameter" do
      component = described_class.new(name: "description", cols: 80)

      expect(component.instance_variable_get(:@cols)).to eq(80)
    end

    it "uses default resize when not specified" do
      component = described_class.new(name: "description")

      expect(component.instance_variable_get(:@resize)).to eq(Form::Field::TextareaComponent::DEFAULT_RESIZE)
    end

    it "accepts resize parameter" do
      component = described_class.new(name: "description", resize: :none)

      expect(component.instance_variable_get(:@resize)).to eq(:none)
    end

    it "accepts maxlength parameter" do
      component = described_class.new(name: "description", maxlength: 500)

      expect(component.instance_variable_get(:@maxlength)).to eq(500)
    end

    it "accepts minlength parameter" do
      component = described_class.new(name: "description", minlength: 10)

      expect(component.instance_variable_get(:@minlength)).to eq(10)
    end

    it "converts resize to symbol" do
      component = described_class.new(name: "description", resize: "horizontal")

      expect(component.instance_variable_get(:@resize)).to eq(:horizontal)
    end
  end

  describe "resize validation" do
    Form::Field::TextareaComponent::RESIZE_OPTIONS.each do |resize|
      it "accepts valid #{resize} resize option" do
        expect {
          described_class.new(name: "field", resize: resize)
        }.not_to raise_error
      end
    end

    it "raises error for invalid resize option" do
      expect {
        described_class.new(name: "field", resize: :invalid)
      }.to raise_error(ArgumentError, /Invalid resize: invalid/)
    end

    it "includes valid options in error message" do
      expect {
        described_class.new(name: "field", resize: :bad)
      }.to raise_error(ArgumentError, /none, vertical, horizontal, both/)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders textarea with name" do
        render_inline(described_class.new(name: "description"))

        expect(page).to have_css('textarea[name="description"]')
      end

      it "renders textarea with generated id" do
        render_inline(described_class.new(name: "user[bio]"))

        expect(page).to have_css('textarea#user_bio')
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "description", label: "Description"))

        expect(page).to have_css('label[for="description"]', text: "Description")
      end

      it "renders placeholder when provided" do
        render_inline(described_class.new(
          name: "description",
          placeholder: "Enter description..."
        ))

        expect(page).to have_css('textarea[placeholder="Enter description..."]')
      end

      it "renders value when provided" do
        render_inline(described_class.new(
          name: "description",
          value: "Test content"
        ))

        expect(page).to have_css('textarea', text: "Test content")
      end

      it "renders hint when provided" do
        render_inline(described_class.new(
          name: "description",
          hint: "Maximum 500 characters"
        ))

        expect(page).to have_css('p#description-hint', text: "Maximum 500 characters")
      end

      it "renders error when provided" do
        render_inline(described_class.new(
          name: "description",
          error: "can't be blank"
        ))

        expect(page).to have_css('p#description-error[role="alert"]', text: "can't be blank")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(
          name: "description",
          hint: "Help",
          error: "Invalid"
        ))

        expect(page).to have_css('p#description-error')
        expect(page).not_to have_css('p#description-hint')
      end
    end

    context "with rows and cols" do
      it "renders with default rows" do
        render_inline(described_class.new(name: "description"))

        expect(page).to have_css("textarea[rows='4']")
      end

      it "renders with custom rows" do
        render_inline(described_class.new(name: "description", rows: 10))

        expect(page).to have_css("textarea[rows='10']")
      end

      it "renders with custom cols when provided" do
        render_inline(described_class.new(name: "description", cols: 80))

        expect(page).to have_css("textarea[cols='80']")
      end

      it "does not render cols attribute when not provided" do
        render_inline(described_class.new(name: "description"))

        expect(page).not_to have_css("textarea[cols]")
      end
    end

    context "with resize options" do
      it "applies vertical resize classes by default" do
        render_inline(described_class.new(name: "description"))

        expect(page).to have_css('textarea.resize-y')
      end

      it "applies none resize classes" do
        render_inline(described_class.new(name: "description", resize: :none))

        expect(page).to have_css('textarea.resize-none')
      end

      it "applies vertical resize classes" do
        render_inline(described_class.new(name: "description", resize: :vertical))

        expect(page).to have_css('textarea.resize-y')
      end

      it "applies horizontal resize classes" do
        render_inline(described_class.new(name: "description", resize: :horizontal))

        expect(page).to have_css('textarea.resize-x')
      end

      it "applies both resize classes" do
        render_inline(described_class.new(name: "description", resize: :both))

        expect(page).to have_css('textarea.resize')
      end
    end

    context "with length constraints" do
      it "renders maxlength attribute when provided" do
        render_inline(described_class.new(name: "description", maxlength: 500))

        expect(page).to have_css("textarea[maxlength='500']")
      end

      it "renders minlength attribute when provided" do
        render_inline(described_class.new(name: "description", minlength: 10))

        expect(page).to have_css("textarea[minlength='10']")
      end

      it "does not render maxlength when not provided" do
        render_inline(described_class.new(name: "description"))

        expect(page).not_to have_css("textarea[maxlength]")
      end

      it "does not render minlength when not provided" do
        render_inline(described_class.new(name: "description"))

        expect(page).not_to have_css("textarea[minlength]")
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(
          name: "description",
          label: "Description",
          required: true
        ))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on textarea" do
        render_inline(described_class.new(name: "description", required: true))

        expect(page).to have_css('textarea[required]')
      end

      it "includes aria-required attribute when required" do
        render_inline(described_class.new(name: "description", label: "Description", required: true))

        expect(page).to have_css('textarea[aria-required="true"]')
      end

      it "does not include aria-required when not required" do
        render_inline(described_class.new(name: "description", label: "Description", required: false))

        expect(page).not_to have_css('textarea[aria-required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on textarea" do
        render_inline(described_class.new(name: "description", disabled: true))

        expect(page).to have_css('textarea[disabled]')
      end

      it "applies disabled styling" do
        render_inline(described_class.new(name: "description", disabled: true))

        expect(page).to have_css('textarea.bg-slate-100.cursor-not-allowed')
      end
    end

    context "with readonly state" do
      it "includes readonly attribute on textarea" do
        render_inline(described_class.new(name: "description", readonly: true))

        expect(page).to have_css('textarea[readonly]')
      end
    end

    context "with error state" do
      it "applies error styling to textarea" do
        render_inline(described_class.new(name: "description", error: "Invalid"))

        expect(page).to have_css('textarea.border-red-400')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "description", error: "Invalid"))

        expect(page).to have_css('textarea[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "description", error: "Invalid"))

        expect(page).to have_css('textarea[aria-describedby="description-error"]')
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "description",
          label: "Description",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('textarea.px-3.py-2.text-xs')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "description",
          label: "Description",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('textarea.px-3\\.5.py-2\\.5.text-sm')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "description",
          label: "Description",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('textarea.px-4.py-3.text-base')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "description", class: "custom-class"))

        expect(page).to have_css('textarea.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "description",
          data: { controller: "textarea" }
        ))

        expect(page).to have_css('textarea[data-controller="textarea"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "description", label: "Description"))

      expect(page).to have_css('label')
    end

    it "associates label with textarea via for attribute" do
      render_inline(described_class.new(
        name: "description",
        id: "user_bio",
        label: "Bio"
      ))

      expect(page).to have_css('label[for="user_bio"]')
      expect(page).to have_css('textarea#user_bio')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "description", hint: "Help"))

      expect(page).to have_css('textarea[aria-describedby="description-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "description", error: "Invalid"))

      expect(page).to have_css('textarea[aria-describedby="description-error"]')
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "description", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end
  end

  describe "edge cases" do
    it "handles nil value" do
      render_inline(described_class.new(name: "description", value: nil))

      expect(page).to have_css('textarea')
      expect(page).to have_css('textarea:not([value])')
    end

    it "handles empty string value" do
      render_inline(described_class.new(name: "description", value: ""))

      expect(page).to have_css('textarea', text: "")
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[profile][bio]",
        label: "Bio"
      ))

      expect(page).to have_css('textarea#user_profile_bio')
      expect(page).to have_css('textarea[name="user[profile][bio]"]')
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[bio]",
        value: "Test bio",
        label: "Biography",
        placeholder: "Tell us about yourself",
        hint: "Maximum 500 characters",
        error: "is too long",
        required: true,
        rows: 8,
        cols: 80,
        maxlength: 500,
        resize: :none,
        size: :large,
        class: "custom-class"
      ))

      expect(page).to have_css('textarea[name="user[bio]"]')
      expect(page).to have_css('textarea', text: "Test bio")
      expect(page).to have_css('label', text: "Biography")
      expect(page).to have_css('label span', text: "*")
      expect(page).to have_css('p[role="alert"]', text: "is too long")
      expect(page).to have_css('textarea.custom-class')
      expect(page).to have_css("textarea[rows='8']")
      expect(page).to have_css("textarea[cols='80']")
      expect(page).to have_css("textarea[maxlength='500']")
      expect(page).to have_css('textarea.resize-none')
    end
  end
end
