# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::BaseComponent, type: :component do
  # Create a concrete test component since BaseComponent is abstract
  before do
    stub_const("TestFieldComponent", Class.new(described_class) do
      def initialize(name:, **options)
        super
      end

      def call
        tag.div(class: wrapper_classes) do
          concat(tag.label(@label, for: @id, class: label_classes) { concat(@label); concat(required_indicator_html) }) if has_label?
          concat(tag.input(type: "text", value: @value, class: field_classes, **base_field_attributes))
          concat(tag.p(@hint, id: hint_id, class: hint_classes)) if has_hint? && !has_error?
          concat(tag.p(@error, id: error_id, class: error_classes)) if has_error?
        end
      end

      def field_classes
        [ base_field_classes, size_field_classes, state_field_classes, @html_attributes[:class] ].compact.join(" ")
      end
    end)
  end

  let(:test_component_class) { TestFieldComponent }

  describe "initialization" do
    context "with required name parameter" do
      it "initializes with name" do
        component = test_component_class.new(name: "email")

        expect(component.instance_variable_get(:@name)).to eq("email")
      end

      it "generates id from name" do
        component = test_component_class.new(name: "user[email]")

        expect(component.instance_variable_get(:@id)).to eq("user_email")
      end

      it "uses custom id when provided" do
        component = test_component_class.new(name: "email", id: "custom_id")

        expect(component.instance_variable_get(:@id)).to eq("custom_id")
      end
    end

    context "with default size" do
      it "uses medium size by default" do
        component = test_component_class.new(name: "field")

        expect(component.instance_variable_get(:@size)).to eq(:medium)
      end

      it "accepts custom size" do
        component = test_component_class.new(name: "field", size: :large)

        expect(component.instance_variable_get(:@size)).to eq(:large)
      end

      it "converts string size to symbol" do
        component = test_component_class.new(name: "field", size: "small")

        expect(component.instance_variable_get(:@size)).to eq(:small)
      end
    end

    context "with optional parameters" do
      it "accepts value" do
        component = test_component_class.new(name: "field", value: "test value")

        expect(component.instance_variable_get(:@value)).to eq("test value")
      end

      it "accepts label" do
        component = test_component_class.new(name: "field", label: "Email Address")

        expect(component.instance_variable_get(:@label)).to eq("Email Address")
      end

      it "accepts placeholder" do
        component = test_component_class.new(name: "field", placeholder: "Enter email")

        expect(component.instance_variable_get(:@placeholder)).to eq("Enter email")
      end

      it "accepts hint" do
        component = test_component_class.new(name: "field", hint: "Help text")

        expect(component.instance_variable_get(:@hint)).to eq("Help text")
      end

      it "accepts single error string" do
        component = test_component_class.new(name: "field", error: "is invalid")

        expect(component.instance_variable_get(:@error)).to eq("is invalid")
      end

      it "accepts array of errors" do
        component = test_component_class.new(name: "field", error: [ "is invalid", "is too short" ])

        expect(component.instance_variable_get(:@error)).to eq("is invalid, is too short")
      end

      it "accepts boolean flags" do
        component = test_component_class.new(
          name: "field",
          required: true,
          disabled: true,
          readonly: true
        )

        expect(component.instance_variable_get(:@required)).to be true
        expect(component.instance_variable_get(:@disabled)).to be true
        expect(component.instance_variable_get(:@readonly)).to be true
      end

      it "accepts html_attributes" do
        component = test_component_class.new(name: "field", class: "custom-class", data: { test: "value" })

        expect(component.instance_variable_get(:@html_attributes)).to include(class: "custom-class", data: { test: "value" })
      end
    end
  end

  describe "size validation" do
    it "accepts valid small size" do
      expect {
        test_component_class.new(name: "field", size: :small)
      }.not_to raise_error
    end

    it "accepts valid medium size" do
      expect {
        test_component_class.new(name: "field", size: :medium)
      }.not_to raise_error
    end

    it "accepts valid large size" do
      expect {
        test_component_class.new(name: "field", size: :large)
      }.not_to raise_error
    end

    it "raises error for invalid size" do
      expect {
        test_component_class.new(name: "field", size: :invalid)
      }.to raise_error(ArgumentError, /Invalid size: invalid/)
    end

    it "includes valid sizes in error message" do
      expect {
        test_component_class.new(name: "field", size: :bad)
      }.to raise_error(ArgumentError, /small, medium, large/)
    end
  end

  describe "#sanitize_id" do
    it "converts brackets to underscores" do
      component = test_component_class.new(name: "user[email]")

      expect(component.instance_variable_get(:@id)).to eq("user_email")
    end

    it "handles nested brackets" do
      component = test_component_class.new(name: "user[address][city]")

      expect(component.instance_variable_get(:@id)).to eq("user_address_city")
    end

    it "removes trailing underscores" do
      component = test_component_class.new(name: "user[email][]")

      expect(component.instance_variable_get(:@id)).to eq("user_email")
    end

    it "collapses multiple underscores" do
      component = test_component_class.new(name: "user__email")

      expect(component.instance_variable_get(:@id)).to eq("user_email")
    end

    it "handles simple names unchanged" do
      component = test_component_class.new(name: "email")

      expect(component.instance_variable_get(:@id)).to eq("email")
    end
  end

  describe "#normalize_error" do
    it "returns nil for nil error" do
      component = test_component_class.new(name: "field", error: nil)

      expect(component.instance_variable_get(:@error)).to be_nil
    end

    it "returns nil for empty string error" do
      component = test_component_class.new(name: "field", error: "")

      expect(component.instance_variable_get(:@error)).to be_nil
    end

    it "returns nil for empty array error" do
      component = test_component_class.new(name: "field", error: [])

      expect(component.instance_variable_get(:@error)).to be_nil
    end

    it "returns string for single string error" do
      component = test_component_class.new(name: "field", error: "is invalid")

      expect(component.instance_variable_get(:@error)).to eq("is invalid")
    end

    it "joins multiple errors with comma" do
      component = test_component_class.new(name: "field", error: [ "is invalid", "is required" ])

      expect(component.instance_variable_get(:@error)).to eq("is invalid, is required")
    end

    it "converts single element array to string" do
      component = test_component_class.new(name: "field", error: [ "is invalid" ])

      expect(component.instance_variable_get(:@error)).to eq("is invalid")
    end
  end

  describe "#hint_id" do
    it "returns hint id when hint is present" do
      component = test_component_class.new(name: "field", id: "test", hint: "Help text")

      expect(component.hint_id).to eq("test-hint")
    end

    it "returns nil when hint is not present" do
      component = test_component_class.new(name: "field", id: "test")

      expect(component.hint_id).to be_nil
    end

    it "uses generated id in hint id" do
      component = test_component_class.new(name: "user[email]", hint: "Help")

      expect(component.hint_id).to eq("user_email-hint")
    end
  end

  describe "#error_id" do
    it "returns error id when error is present" do
      component = test_component_class.new(name: "field", id: "test", error: "Invalid")

      expect(component.error_id).to eq("test-error")
    end

    it "returns nil when error is not present" do
      component = test_component_class.new(name: "field", id: "test")

      expect(component.error_id).to be_nil
    end

    it "uses generated id in error id" do
      component = test_component_class.new(name: "user[email]", error: "Invalid")

      expect(component.error_id).to eq("user_email-error")
    end
  end

  describe "#has_error?" do
    it "returns true when error is present" do
      component = test_component_class.new(name: "field", error: "Invalid")

      expect(component.has_error?).to be true
    end

    it "returns false when error is nil" do
      component = test_component_class.new(name: "field", error: nil)

      expect(component.has_error?).to be false
    end

    it "returns false when error is empty string" do
      component = test_component_class.new(name: "field", error: "")

      expect(component.has_error?).to be false
    end
  end

  describe "#has_label?" do
    it "returns true when label is present" do
      component = test_component_class.new(name: "field", label: "Email")

      expect(component.has_label?).to be true
    end

    it "returns false when label is nil" do
      component = test_component_class.new(name: "field", label: nil)

      expect(component.has_label?).to be false
    end

    it "returns false when label is empty string" do
      component = test_component_class.new(name: "field", label: "")

      expect(component.has_label?).to be false
    end
  end

  describe "#has_hint?" do
    it "returns true when hint is present" do
      component = test_component_class.new(name: "field", hint: "Help text")

      expect(component.has_hint?).to be true
    end

    it "returns false when hint is nil" do
      component = test_component_class.new(name: "field", hint: nil)

      expect(component.has_hint?).to be false
    end

    it "returns false when hint is empty string" do
      component = test_component_class.new(name: "field", hint: "")

      expect(component.has_hint?).to be false
    end
  end

  describe "#aria_describedby" do
    it "returns nil when no hint or error" do
      component = test_component_class.new(name: "field")

      expect(component.send(:aria_describedby)).to be_nil
    end

    it "returns hint id when only hint is present" do
      component = test_component_class.new(name: "test", hint: "Help")

      expect(component.send(:aria_describedby)).to eq("test-hint")
    end

    it "returns error id when only error is present" do
      component = test_component_class.new(name: "test", error: "Invalid")

      expect(component.send(:aria_describedby)).to eq("test-error")
    end

    it "returns only error id when both hint and error are present" do
      component = test_component_class.new(name: "test", hint: "Help", error: "Invalid")

      expect(component.send(:aria_describedby)).to eq("test-error")
    end
  end

  describe "#required_indicator" do
    it "returns asterisk when required is true" do
      component = test_component_class.new(name: "field", required: true)

      expect(component.send(:required_indicator)).to eq("*")
    end

    it "returns nil when required is false" do
      component = test_component_class.new(name: "field", required: false)

      expect(component.send(:required_indicator)).to be_nil
    end
  end

  describe "#required_indicator_html" do
    it "returns HTML span when required is true" do
      component = test_component_class.new(name: "field", required: true)
      html = component.send(:required_indicator_html)

      expect(html).to be_html_safe
      expect(html).to include("*")
      expect(html).to include("text-red-500")
      expect(html).to include('aria-hidden="true"')
    end

    it "returns nil when required is false" do
      component = test_component_class.new(name: "field", required: false)

      expect(component.send(:required_indicator_html)).to be_nil
    end
  end

  describe "CSS class methods" do
    describe "#wrapper_classes" do
      it "returns form-field class" do
        component = test_component_class.new(name: "field")

        expect(component.send(:wrapper_classes)).to eq("form-field")
      end
    end

    describe "#label_classes" do
      it "includes base label styles" do
        component = test_component_class.new(name: "field", size: :medium)
        classes = component.send(:label_classes)

        expect(classes).to include("block")
        expect(classes).to include("font-semibold")
        expect(classes).to include("text-slate-700")
      end

      it "includes small size class" do
        component = test_component_class.new(name: "field", size: :small)

        expect(component.send(:label_classes)).to include("text-xs")
      end

      it "includes medium size class" do
        component = test_component_class.new(name: "field", size: :medium)

        expect(component.send(:label_classes)).to include("text-sm")
      end

      it "includes large size class" do
        component = test_component_class.new(name: "field", size: :large)

        expect(component.send(:label_classes)).to include("text-base")
      end
    end

    describe "#hint_classes" do
      it "returns hint styling classes" do
        component = test_component_class.new(name: "field")
        classes = component.send(:hint_classes)

        expect(classes).to include("text-slate-600")
        expect(classes).to include("text-xs")
      end
    end

    describe "#error_classes" do
      it "returns error styling classes" do
        component = test_component_class.new(name: "field")
        classes = component.send(:error_classes)

        expect(classes).to include("text-red-600")
        expect(classes).to include("text-xs")
        expect(classes).to include("font-medium")
      end
    end

    describe "#base_field_classes" do
      it "includes base field styles" do
        component = test_component_class.new(name: "field")
        classes = component.send(:base_field_classes)

        expect(classes).to include("block")
        expect(classes).to include("w-full")
        expect(classes).to include("border-2")
        expect(classes).to include("rounded-lg")
      end

      it "includes focus ring classes" do
        component = test_component_class.new(name: "field")
        classes = component.send(:base_field_classes)

        expect(classes).to include("focus:outline-none")
        expect(classes).to include("focus:ring-2")
      end
    end

    describe "#size_field_classes" do
      it "returns small padding for small size" do
        component = test_component_class.new(name: "field", size: :small)
        classes = component.send(:size_field_classes)

        expect(classes).to include("px-3")
        expect(classes).to include("py-2")
        expect(classes).to include("text-xs")
      end

      it "returns medium padding for medium size" do
        component = test_component_class.new(name: "field", size: :medium)
        classes = component.send(:size_field_classes)

        expect(classes).to include("px-3.5")
        expect(classes).to include("py-2.5")
        expect(classes).to include("text-sm")
      end

      it "returns large padding for large size" do
        component = test_component_class.new(name: "field", size: :large)
        classes = component.send(:size_field_classes)

        expect(classes).to include("px-4")
        expect(classes).to include("py-3")
        expect(classes).to include("text-base")
      end
    end

    describe "#state_field_classes" do
      it "returns error styles when has error" do
        component = test_component_class.new(name: "field", error: "Invalid")
        classes = component.send(:state_field_classes)

        expect(classes).to include("border-red-400")
        expect(classes).to include("bg-red-50/50")
        expect(classes).to include("text-red-900")
      end

      it "returns disabled styles when disabled" do
        component = test_component_class.new(name: "field", disabled: true)
        classes = component.send(:state_field_classes)

        expect(classes).to include("bg-slate-100")
        expect(classes).to include("cursor-not-allowed")
      end

      it "returns normal styles when no error and not disabled" do
        component = test_component_class.new(name: "field")
        classes = component.send(:state_field_classes)

        expect(classes).to include("border-slate-300")
        expect(classes).to include("bg-white")
        expect(classes).to include("focus:border-indigo-500")
      end

      it "prefers error styles over disabled styles" do
        component = test_component_class.new(name: "field", error: "Invalid", disabled: true)
        classes = component.send(:state_field_classes)

        expect(classes).to include("border-red-400")
        expect(classes).not_to include("cursor-not-allowed")
      end
    end
  end

  describe "#base_field_attributes" do
    it "includes name attribute" do
      component = test_component_class.new(name: "email")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:name]).to eq("email")
    end

    it "includes id attribute" do
      component = test_component_class.new(name: "email", id: "user_email")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:id]).to eq("user_email")
    end

    it "includes placeholder when provided" do
      component = test_component_class.new(name: "email", placeholder: "Enter email")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:placeholder]).to eq("Enter email")
    end

    it "omits placeholder when not provided" do
      component = test_component_class.new(name: "email")
      attrs = component.send(:base_field_attributes)

      expect(attrs).not_to have_key(:placeholder)
    end

    it "includes required attribute when true" do
      component = test_component_class.new(name: "email", required: true)
      attrs = component.send(:base_field_attributes)

      expect(attrs[:required]).to be true
    end

    it "omits required attribute when false" do
      component = test_component_class.new(name: "email", required: false)
      attrs = component.send(:base_field_attributes)

      expect(attrs).not_to have_key(:required)
    end

    it "includes disabled attribute when true" do
      component = test_component_class.new(name: "email", disabled: true)
      attrs = component.send(:base_field_attributes)

      expect(attrs[:disabled]).to be true
    end

    it "includes readonly attribute when true" do
      component = test_component_class.new(name: "email", readonly: true)
      attrs = component.send(:base_field_attributes)

      expect(attrs[:readonly]).to be true
    end

    it "includes aria-invalid when has error" do
      component = test_component_class.new(name: "email", error: "Invalid")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:"aria-invalid"]).to eq("true")
    end

    it "omits aria-invalid when no error" do
      component = test_component_class.new(name: "email")
      attrs = component.send(:base_field_attributes)

      expect(attrs).not_to have_key(:"aria-invalid")
    end

    it "includes aria-describedby when hint is present" do
      component = test_component_class.new(name: "test", hint: "Help")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:"aria-describedby"]).to eq("test-hint")
    end

    it "includes aria-describedby when error is present" do
      component = test_component_class.new(name: "test", error: "Invalid")
      attrs = component.send(:base_field_attributes)

      expect(attrs[:"aria-describedby"]).to eq("test-error")
    end
  end

  describe "#merge_html_attributes" do
    it "merges custom attributes into base attributes" do
      component = test_component_class.new(name: "email", data: { controller: "test" })
      attrs = component.send(:merge_html_attributes, { id: "field" })

      expect(attrs[:data]).to eq({ controller: "test" })
    end

    it "excludes class from html_attributes" do
      component = test_component_class.new(name: "email", class: "custom-class", data: { test: "value" })
      attrs = component.send(:merge_html_attributes, {})

      expect(attrs).not_to have_key(:class)
      expect(attrs[:data]).to eq({ test: "value" })
    end

    it "preserves base attributes" do
      component = test_component_class.new(name: "email", data: { controller: "test" })
      base_attrs = { id: "field", name: "email" }
      attrs = component.send(:merge_html_attributes, base_attrs)

      expect(attrs[:id]).to eq("field")
      expect(attrs[:name]).to eq("email")
    end
  end

  describe "#flatten_attributes" do
    it "flattens nested data attributes" do
      component = test_component_class.new(name: "field")
      attrs = { data: { controller: "test", action: "click" } }
      flattened = component.send(:flatten_attributes, attrs)

      expect(flattened).to eq({ "data-controller" => "test", "data-action" => "click" })
    end

    it "handles deeply nested attributes" do
      component = test_component_class.new(name: "field")
      attrs = { data: { components: { modal: { value: "test" } } } }
      flattened = component.send(:flatten_attributes, attrs)

      expect(flattened).to eq({ "data-components-modal-value" => "test" })
    end

    it "handles simple attributes" do
      component = test_component_class.new(name: "field")
      attrs = { id: "test", class: "custom" }
      flattened = component.send(:flatten_attributes, attrs)

      expect(flattened).to eq({ "id" => "test", "class" => "custom" })
    end

    it "handles mixed simple and nested attributes" do
      component = test_component_class.new(name: "field")
      attrs = { id: "test", data: { controller: "modal" } }
      flattened = component.send(:flatten_attributes, attrs)

      expect(flattened).to eq({ "id" => "test", "data-controller" => "modal" })
    end
  end

  describe "#flattened_html_attributes" do
    it "returns empty string when no html_attributes" do
      component = test_component_class.new(name: "field")

      expect(component.send(:flattened_html_attributes)).to eq("")
    end

    it "returns flattened attributes string" do
      component = test_component_class.new(name: "field", data: { controller: "test" })
      result = component.send(:flattened_html_attributes)

      expect(result).to be_html_safe
      expect(result).to include('data-controller="test"')
    end

    it "escapes attribute values" do
      component = test_component_class.new(name: "field", data: { value: "<script>alert('xss')</script>" })
      result = component.send(:flattened_html_attributes)

      expect(result).to include("&lt;script&gt;")
      expect(result).not_to include("<script>")
    end

    it "handles multiple attributes" do
      component = test_component_class.new(name: "field", class: "custom", data: { controller: "test", action: "click" })
      result = component.send(:flattened_html_attributes)

      expect(result).to include('class="custom"')
      expect(result).to include('data-controller="test"')
      expect(result).to include('data-action="click"')
    end
  end

  describe "choice input helpers (checkbox/radio)" do
    describe "#base_choice_input_classes" do
      it "returns square shape for checkbox" do
        component = test_component_class.new(name: "field")
        classes = component.send(:base_choice_input_classes, shape: :square)

        expect(classes).to include("rounded")
        expect(classes).not_to include("rounded-full")
      end

      it "returns circle shape for radio" do
        component = test_component_class.new(name: "field")
        classes = component.send(:base_choice_input_classes, shape: :circle)

        expect(classes).to include("rounded-full")
      end

      it "includes common choice input styles" do
        component = test_component_class.new(name: "field")
        classes = component.send(:base_choice_input_classes, shape: :square)

        expect(classes).to include("border")
        expect(classes).to include("focus:outline-none")
        expect(classes).to include("focus:ring-2")
      end
    end

    describe "#size_choice_input_classes" do
      it "returns small dimensions for small size" do
        component = test_component_class.new(name: "field", size: :small)
        classes = component.send(:size_choice_input_classes)

        expect(classes).to include("h-3.5")
        expect(classes).to include("w-3.5")
      end

      it "returns medium dimensions for medium size" do
        component = test_component_class.new(name: "field", size: :medium)
        classes = component.send(:size_choice_input_classes)

        expect(classes).to include("h-4")
        expect(classes).to include("w-4")
      end

      it "returns large dimensions for large size" do
        component = test_component_class.new(name: "field", size: :large)
        classes = component.send(:size_choice_input_classes)

        expect(classes).to include("h-5")
        expect(classes).to include("w-5")
      end
    end

    describe "#state_choice_input_classes" do
      it "returns error styles when has error" do
        component = test_component_class.new(name: "field", error: "Invalid")
        classes = component.send(:state_choice_input_classes)

        expect(classes).to include("border-red-300")
        expect(classes).to include("text-red-600")
      end

      it "returns disabled styles when disabled" do
        component = test_component_class.new(name: "field", disabled: true)
        classes = component.send(:state_choice_input_classes)

        expect(classes).to include("bg-slate-100")
        expect(classes).to include("cursor-not-allowed")
      end

      it "returns normal styles when no error and not disabled" do
        component = test_component_class.new(name: "field")
        classes = component.send(:state_choice_input_classes)

        expect(classes).to include("border-slate-300")
        expect(classes).to include("text-blue-600")
      end
    end

    describe "#choice_label_classes" do
      it "includes base label styles" do
        component = test_component_class.new(name: "field")
        classes = component.send(:choice_label_classes)

        expect(classes).to include("text-slate-700")
        expect(classes).to include("cursor-pointer")
        expect(classes).to include("select-none")
      end

      it "includes disabled styles when disabled" do
        component = test_component_class.new(name: "field", disabled: true)
        classes = component.send(:choice_label_classes)

        expect(classes).to include("cursor-not-allowed")
        expect(classes).to include("opacity-60")
      end

      it "includes small size class" do
        component = test_component_class.new(name: "field", size: :small)
        classes = component.send(:choice_label_classes)

        expect(classes).to include("text-xs")
      end

      it "includes medium size class" do
        component = test_component_class.new(name: "field", size: :medium)
        classes = component.send(:choice_label_classes)

        expect(classes).to include("text-sm")
      end

      it "includes large size class" do
        component = test_component_class.new(name: "field", size: :large)
        classes = component.send(:choice_label_classes)

        expect(classes).to include("text-base")
      end
    end
  end

  describe "rendering with test component" do
    it "renders label when provided" do
      render_inline(test_component_class.new(name: "email", label: "Email Address"))

      expect(page).to have_css("label", text: "Email Address")
    end

    it "renders required indicator in label" do
      render_inline(test_component_class.new(name: "email", label: "Email", required: true))

      expect(page).to have_css("label span.text-red-500", text: "*")
    end

    it "renders hint when provided" do
      render_inline(test_component_class.new(name: "email", hint: "Enter your email address"))

      expect(page).to have_css("p#email-hint", text: "Enter your email address")
    end

    it "renders error instead of hint when both present" do
      render_inline(test_component_class.new(name: "email", hint: "Help text", error: "is invalid"))

      expect(page).to have_css("p#email-error", text: "is invalid")
      expect(page).not_to have_css("p#email-hint")
    end

    it "renders error when provided" do
      render_inline(test_component_class.new(name: "email", error: "is invalid"))

      expect(page).to have_css("p#email-error", text: "is invalid")
    end

    it "applies error state classes to input" do
      render_inline(test_component_class.new(name: "email", error: "is invalid"))

      expect(page).to have_css("input.border-red-400")
    end

    it "applies disabled state classes to input" do
      render_inline(test_component_class.new(name: "email", disabled: true))

      expect(page).to have_css("input.bg-slate-100")
      expect(page).to have_css("input.cursor-not-allowed")
    end

    it "sets aria-invalid on input when has error" do
      render_inline(test_component_class.new(name: "email", error: "is invalid"))

      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "sets aria-describedby to hint id when hint present" do
      render_inline(test_component_class.new(name: "email", hint: "Help text"))

      expect(page).to have_css('input[aria-describedby="email-hint"]')
    end

    it "sets aria-describedby to error id when error present" do
      render_inline(test_component_class.new(name: "email", error: "is invalid"))

      expect(page).to have_css('input[aria-describedby="email-error"]')
    end

    it "applies small size classes" do
      render_inline(test_component_class.new(name: "email", label: "Email", size: :small))

      expect(page).to have_css("label.text-xs")
      expect(page).to have_css("input.px-3.py-2.text-xs")
    end

    it "applies medium size classes" do
      render_inline(test_component_class.new(name: "email", label: "Email", size: :medium))

      expect(page).to have_css("label.text-sm")
      expect(page).to have_css("input.px-3\\.5.py-2\\.5.text-sm")
    end

    it "applies large size classes" do
      render_inline(test_component_class.new(name: "email", label: "Email", size: :large))

      expect(page).to have_css("label.text-base")
      expect(page).to have_css("input.px-4.py-3.text-base")
    end
  end

  describe "edge cases" do
    it "handles special characters in label" do
      render_inline(test_component_class.new(name: "field", label: "Email <script>alert('xss')</script>"))

      expect(page).to have_text("Email")
      expect(page).not_to have_css("script")
    end

    it "handles special characters in hint" do
      render_inline(test_component_class.new(name: "field", hint: "Help <b>text</b>"))

      expect(page).to have_text("Help")
      expect(page).not_to have_css("b")
    end

    it "handles special characters in error" do
      render_inline(test_component_class.new(name: "field", error: "Error <script>alert('xss')</script>"))

      expect(page).to have_text("Error")
      expect(page).not_to have_css("script")
    end

    it "handles complex nested name" do
      render_inline(test_component_class.new(name: "user[addresses][0][street]", label: "Street"))

      expect(page).to have_css('input#user_addresses_0_street')
      expect(page).to have_css('input[name="user[addresses][0][street]"]')
    end

    it "combines multiple configuration options" do
      render_inline(test_component_class.new(
        name: "user[email]",
        id: "custom_email",
        value: "test@example.com",
        label: "Email Address",
        placeholder: "Enter email",
        hint: "We'll never share your email",
        error: "is invalid, is too short",
        required: true,
        disabled: false,
        size: :large,
        class: "custom-class",
        data: { controller: "email" }
      ))

      expect(page).to have_css('input#custom_email')
      expect(page).to have_css('input[name="user[email]"]')
      expect(page).to have_css('input[value="test@example.com"]')
      expect(page).to have_css('label', text: "Email Address")
      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('p#custom_email-error', text: "is invalid, is too short")
      expect(page).not_to have_css('p#custom_email-hint')
      expect(page).to have_css('input[required]')
      expect(page).to have_css('input.custom-class')
    end
  end
end
