# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::TextInputComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "email")

      expect(component).to be_a(described_class)
    end

    it "accepts custom type" do
      component = described_class.new(name: "phone", type: :tel)

      expect(component.instance_variable_get(:@type)).to eq(:tel)
    end

    it "uses text type by default" do
      component = described_class.new(name: "field")

      expect(component.instance_variable_get(:@type)).to eq(:text)
    end

    it "converts string type to symbol" do
      component = described_class.new(name: "field", type: "email")

      expect(component.instance_variable_get(:@type)).to eq(:email)
    end
  end

  describe "type validation" do
    Form::Field::TextInputComponent::TYPES.each do |type|
      it "accepts valid #{type} type" do
        expect {
          described_class.new(name: "field", type: type)
        }.not_to raise_error
      end
    end

    it "raises error for invalid type" do
      expect {
        described_class.new(name: "field", type: :invalid)
      }.to raise_error(ArgumentError, /Invalid type: invalid/)
    end

    it "includes valid types in error message" do
      expect {
        described_class.new(name: "field", type: :bad)
      }.to raise_error(ArgumentError, /text, email, tel, url, search, number/)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders text input with name" do
        render_inline(described_class.new(name: "email"))

        expect(page).to have_css('input[type="text"][name="email"]')
      end

      it "renders input with generated id" do
        render_inline(described_class.new(name: "user[email]"))

        expect(page).to have_css('input#user_email')
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "email", label: "Email Address"))

        expect(page).to have_css('label[for="email"]', text: "Email Address")
      end

      it "renders placeholder when provided" do
        render_inline(described_class.new(name: "email", placeholder: "you@example.com"))

        expect(page).to have_css('input[placeholder="you@example.com"]')
      end

      it "renders value when provided" do
        render_inline(described_class.new(name: "email", value: "test@example.com"))

        expect(page).to have_css('input[value="test@example.com"]')
      end

      it "renders hint when provided" do
        render_inline(described_class.new(name: "email", hint: "Enter your email"))

        expect(page).to have_css('p#email-hint', text: "Enter your email")
      end

      it "renders error when provided" do
        render_inline(described_class.new(name: "email", error: "is invalid"))

        expect(page).to have_css('p#email-error[role="alert"]', text: "is invalid")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(name: "email", hint: "Help", error: "Invalid"))

        expect(page).to have_css('p#email-error')
        expect(page).not_to have_css('p#email-hint')
      end
    end

    context "with different input types" do
      it "renders email type" do
        render_inline(described_class.new(name: "email", type: :email))

        expect(page).to have_css('input[type="email"]')
      end

      it "renders tel type" do
        render_inline(described_class.new(name: "phone", type: :tel))

        expect(page).to have_css('input[type="tel"]')
      end

      it "renders url type" do
        render_inline(described_class.new(name: "website", type: :url))

        expect(page).to have_css('input[type="url"]')
      end

      it "renders search type" do
        render_inline(described_class.new(name: "query", type: :search))

        expect(page).to have_css('input[type="search"]')
      end

      it "renders number type" do
        render_inline(described_class.new(name: "age", type: :number))

        expect(page).to have_css('input[type="number"]')
      end
    end

    context "with icon slots" do
      it "renders leading icon" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_leading { '<svg class="test-icon"></svg>'.html_safe }
        end

        expect(page).to have_css('.absolute.left-0 .test-icon')
      end

      it "renders trailing icon" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_trailing { '<svg class="test-icon"></svg>'.html_safe }
        end

        expect(page).to have_css('.absolute.right-0 .test-icon')
      end

      it "renders both icons" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_leading { '<svg class="leading-icon"></svg>'.html_safe }
          c.with_icon_trailing { '<svg class="trailing-icon"></svg>'.html_safe }
        end

        expect(page).to have_css('.leading-icon')
        expect(page).to have_css('.trailing-icon')
      end

      it "adds left padding when leading icon present" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_leading { '<svg></svg>'.html_safe }
        end

        expect(page).to have_css('input.pl-10')
      end

      it "adds right padding when trailing icon present" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_trailing { '<svg></svg>'.html_safe }
        end

        expect(page).to have_css('input.pr-10')
      end

      it "uses error color for icons when has error" do
        component = described_class.new(name: "email", error: "Invalid")

        render_inline(component) do |c|
          c.with_icon_leading { '<svg></svg>'.html_safe }
        end

        expect(page).to have_css('.text-red-400')
      end

      it "uses slate color for icons when no error" do
        component = described_class.new(name: "email")

        render_inline(component) do |c|
          c.with_icon_leading { '<svg></svg>'.html_safe }
        end

        expect(page).to have_css('.text-slate-400')
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(name: "email", label: "Email", required: true))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on input" do
        render_inline(described_class.new(name: "email", required: true))

        expect(page).to have_css('input[required]')
      end

      it "includes aria-required attribute when required" do
        render_inline(described_class.new(name: "email", label: "Email", required: true))

        expect(page).to have_css('input[aria-required="true"]')
      end

      it "does not include aria-required when not required" do
        render_inline(described_class.new(name: "email", label: "Email", required: false))

        expect(page).not_to have_css('input[aria-required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on input" do
        render_inline(described_class.new(name: "email", disabled: true))

        expect(page).to have_css('input[disabled]')
      end

      it "applies disabled styling" do
        render_inline(described_class.new(name: "email", disabled: true))

        expect(page).to have_css('input.bg-slate-100.cursor-not-allowed')
      end
    end

    context "with readonly state" do
      it "includes readonly attribute on input" do
        render_inline(described_class.new(name: "email", readonly: true))

        expect(page).to have_css('input[readonly]')
      end
    end

    context "with error state" do
      it "applies error styling to input" do
        render_inline(described_class.new(name: "email", error: "Invalid"))

        expect(page).to have_css('input.border-red-400')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "email", error: "Invalid"))

        expect(page).to have_css('input[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "email", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="email-error"]')
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(name: "email", label: "Email", size: :small))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('input.px-3.py-2.text-xs')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(name: "email", label: "Email", size: :medium))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('input.px-3\\.5.py-2\\.5.text-sm')
      end

      it "applies large size classes" do
        render_inline(described_class.new(name: "email", label: "Email", size: :large))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('input.px-4.py-3.text-base')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "email", class: "custom-class"))

        expect(page).to have_css('input.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(name: "email", data: { controller: "email" }))

        expect(page).to have_css('input[data-controller="email"]')
      end

      it "renders with pattern attribute" do
        render_inline(described_class.new(name: "zip", pattern: "[0-9]{5}"))

        expect(page).to have_css('input[pattern="[0-9]{5}"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "email", label: "Email"))

      expect(page).to have_css('label')
    end

    it "associates label with input via for attribute" do
      render_inline(described_class.new(name: "email", id: "user_email", label: "Email"))

      expect(page).to have_css('label[for="user_email"]')
      expect(page).to have_css('input#user_email')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "email", hint: "Help"))

      expect(page).to have_css('input[aria-describedby="email-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "email", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="email-error"]')
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "email", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end
  end

  describe "edge cases" do
    it "handles special characters in label" do
      render_inline(described_class.new(name: "field", label: "Email <script>alert('xss')</script>"))

      expect(page).to have_text("Email")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in value" do
      render_inline(described_class.new(name: "field", value: "<script>alert('xss')</script>"))

      expect(page).to have_css('input')
      expect(page).not_to have_css("script")
    end

    it "handles complex nested name" do
      render_inline(described_class.new(name: "user[addresses][0][street]", label: "Street"))

      expect(page).to have_css('input#user_addresses_0_street')
      expect(page).to have_css('input[name="user[addresses][0][street]"]')
    end

    it "combines multiple configuration options" do
      component = described_class.new(
        name: "user[email]",
        type: :email,
        value: "test@example.com",
        label: "Email Address",
        placeholder: "you@example.com",
        hint: "Enter your email",
        error: "is invalid",
        required: true,
        size: :large,
        class: "custom-class"
      )

      render_inline(component) do |c|
        c.with_icon_leading { '<svg class="icon"></svg>'.html_safe }
      end

      expect(page).to have_css('input[type="email"]')
      expect(page).to have_css('input[value="test@example.com"]')
      expect(page).to have_css('label', text: "Email Address")
      expect(page).to have_css('label span', text: "*")
      expect(page).to have_css('p[role="alert"]', text: "is invalid")
      expect(page).to have_css('input.custom-class')
      expect(page).to have_css('.icon')
      expect(page).to have_css('input.pl-10')
    end
  end
end
