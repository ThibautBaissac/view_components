# frozen_string_literal: true

require "rails_helper"

RSpec.describe HtmlAttributesRendering, type: :concern do
  # Create a dummy component class to test the concern
  let(:component_class) do
    Class.new(ViewComponent::Base) do
      include HtmlAttributesRendering

      attr_reader :html_attributes

      def initialize(**html_attributes)
        @html_attributes = html_attributes
      end

      # Make private methods accessible for testing
      public :html_attributes_string, :attributes_for_rendering, :deep_merge_attributes
    end
  end

  let(:component) { component_class.new }

  describe "#html_attributes_string" do
    context "with basic attributes" do
      it "renders simple string attributes" do
        component = component_class.new(id: "my-id", role: "button")

        result = component.html_attributes_string

        expect(result).to eq('id="my-id" role="button"')
        expect(result).to be_html_safe
      end

      it "excludes class attribute" do
        component = component_class.new(id: "my-id", class: "hidden-class")

        result = component.html_attributes_string

        expect(result).to eq('id="my-id"')
        expect(result).not_to include("class")
      end

      it "converts underscores to hyphens in attribute names" do
        component = component_class.new(aria_label: "Close")

        result = component.html_attributes_string

        expect(result).to eq('aria-label="Close"')
      end

      it "returns empty string when no attributes" do
        component = component_class.new

        result = component.html_attributes_string

        expect(result).to eq("")
        expect(result).to be_html_safe
      end
    end

    context "with boolean attributes" do
      it "renders true as attribute name only" do
        component = component_class.new(disabled: true, readonly: true)

        result = component.html_attributes_string

        expect(result).to eq("disabled readonly")
      end

      it "omits false boolean attributes" do
        component = component_class.new(disabled: false, id: "test")

        result = component.html_attributes_string

        expect(result).to eq('id="test"')
        expect(result).not_to include("disabled")
      end

      it "omits nil attributes" do
        component = component_class.new(disabled: nil, id: "test")

        result = component.html_attributes_string

        expect(result).to eq('id="test"')
      end
    end

    context "with nested hash attributes" do
      it "renders data attributes" do
        component = component_class.new(
          data: { controller: "dropdown", action: "click->dropdown#toggle" }
        )

        result = component.html_attributes_string

        expect(result).to include('data-controller="dropdown"')
        expect(result).to include('data-action="click-&gt;dropdown#toggle"')
      end

      it "renders aria attributes" do
        component = component_class.new(
          aria: { label: "Close modal", hidden: "true" }
        )

        result = component.html_attributes_string

        expect(result).to include('aria-label="Close modal"')
        expect(result).to include('aria-hidden="true"')
      end

      it "converts underscores to hyphens in nested keys" do
        component = component_class.new(
          data: { turbo_frame: "modal", turbo_action: "replace" }
        )

        result = component.html_attributes_string

        expect(result).to include('data-turbo-frame="modal"')
        expect(result).to include('data-turbo-action="replace"')
      end

      it "handles multiple nested hashes" do
        component = component_class.new(
          data: { controller: "modal" },
          aria: { label: "Dialog" }
        )

        result = component.html_attributes_string

        expect(result).to include('data-controller="modal"')
        expect(result).to include('aria-label="Dialog"')
      end
    end

    context "with XSS protection" do
      it "escapes HTML in attribute values" do
        component = component_class.new(title: '<script>alert("xss")</script>')

        result = component.html_attributes_string

        expect(result).to include('title="&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;"')
        expect(result).not_to include("<script>")
      end

      it "escapes quotes in attribute values" do
        component = component_class.new(title: 'Quote: "test"')

        result = component.html_attributes_string

        expect(result).to include('title="Quote: &quot;test&quot;"')
      end

      it "escapes HTML entities in nested attributes" do
        component = component_class.new(
          data: { message: '<script>alert("xss")</script>' }
        )

        result = component.html_attributes_string

        expect(result).to include('data-message="&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;"')
        expect(result).not_to include("<script>")
      end

      it "escapes ampersands" do
        component = component_class.new(title: "Rock & Roll")

        result = component.html_attributes_string

        expect(result).to include('title="Rock &amp; Roll"')
      end

      it "returns html_safe result" do
        component = component_class.new(id: "test")

        result = component.html_attributes_string

        expect(result).to be_html_safe
      end
    end

    context "with custom attributes parameter" do
      it "uses provided attributes instead of @html_attributes" do
        component = component_class.new(id: "original")

        result = component.html_attributes_string(id: "override")

        expect(result).to eq('id="override"')
        expect(result).not_to include("original")
      end

      it "still excludes class from custom attributes" do
        component = component_class.new

        result = component.html_attributes_string(id: "test", class: "hidden")

        expect(result).to eq('id="test"')
        expect(result).not_to include("class")
      end
    end

    context "with edge cases" do
      it "handles empty string values" do
        component = component_class.new(id: "", role: "button")

        result = component.html_attributes_string

        expect(result).to include('id=""')
        expect(result).to include('role="button"')
      end

      it "handles numeric values" do
        component = component_class.new(tabindex: 0, maxlength: 100)

        result = component.html_attributes_string

        expect(result).to include('tabindex="0"')
        expect(result).to include('maxlength="100"')
      end

      it "handles mixed attribute types" do
        component = component_class.new(
          id: "test",
          disabled: true,
          hidden: false,
          data: { controller: "modal" },
          aria: { label: "Dialog" }
        )

        result = component.html_attributes_string

        expect(result).to include('id="test"')
        expect(result).to include('disabled')
        expect(result).not_to include('hidden')
        expect(result).to include('data-controller="modal"')
        expect(result).to include('aria-label="Dialog"')
      end
    end
  end

  describe "#attributes_for_rendering" do
    it "returns @html_attributes when defined" do
      component = component_class.new(id: "test", role: "button")

      result = component.attributes_for_rendering

      expect(result).to eq(id: "test", role: "button")
    end

    it "returns empty hash when @html_attributes not defined" do
      component_without_attrs = Class.new(ViewComponent::Base) do
        include HtmlAttributesRendering
        public :attributes_for_rendering
      end.new

      result = component_without_attrs.attributes_for_rendering

      expect(result).to eq({})
    end
  end

  describe "#deep_merge_attributes" do
    context "with regular attributes" do
      it "merges non-conflicting attributes" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { id: "default-id" },
          { role: "button" }
        )

        expect(result).to eq(id: "default-id", role: "button")
      end

      it "overrides conflicting attributes" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { id: "default-id" },
          { id: "override-id" }
        )

        expect(result).to eq(id: "override-id")
      end
    end

    context "with class attributes" do
      it "concatenates class attributes with symbol key" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { class: "base-class" },
          { class: "override-class" }
        )

        expect(result[:class]).to eq("base-class override-class")
      end

      it "concatenates class attributes with string key" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { "class" => "base-class" },
          { "class" => "override-class" }
        )

        expect(result["class"]).to eq("base-class override-class")
      end

      it "handles nil class in defaults" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { id: "test" },
          { class: "custom" }
        )

        expect(result[:class]).to eq("custom")
      end

      it "handles nil class in overrides" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { class: "base" },
          { id: "test" }
        )

        expect(result[:class]).to eq("base")
      end

      it "removes class when both are empty after concatenation" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { class: "" },
          { class: "" }
        )

        expect(result[:class]).to be_nil
      end

      it "handles whitespace-only class values" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { class: "base" },
          { class: "  " }
        )

        expect(result[:class]).to eq("base   ")
      end
    end

    context "with nested hash attributes" do
      it "deep merges data attributes" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { data: { controller: "modal" } },
          { data: { action: "click->modal#close" } }
        )

        expect(result[:data]).to eq(
          controller: "modal",
          action: "click->modal#close"
        )
      end

      it "deep merges aria attributes" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { aria: { label: "Dialog" } },
          { aria: { hidden: "true" } }
        )

        expect(result[:aria]).to eq(
          label: "Dialog",
          hidden: "true"
        )
      end

      it "overrides nested values with same key" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { data: { controller: "modal" } },
          { data: { controller: "dropdown" } }
        )

        expect(result[:data][:controller]).to eq("dropdown")
      end

      it "preserves non-overlapping nested keys" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { data: { controller: "modal", target: "modal.dialog" } },
          { data: { action: "click->modal#close" } }
        )

        expect(result[:data]).to eq(
          controller: "modal",
          target: "modal.dialog",
          action: "click->modal#close"
        )
      end

      it "handles empty nested hashes" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { data: {} },
          { data: { controller: "modal" } }
        )

        expect(result[:data]).to eq(controller: "modal")
      end
    end

    context "with complex merging scenarios" do
      it "merges multiple attribute types together" do
        component = component_class.new

        result = component.deep_merge_attributes(
          {
            id: "default",
            class: "base-class",
            data: { controller: "modal" },
            aria: { label: "Dialog" }
          },
          {
            role: "dialog",
            class: "custom-class",
            data: { action: "click->modal#close" },
            aria: { hidden: "false" }
          }
        )

        expect(result).to eq(
          id: "default",
          role: "dialog",
          class: "base-class custom-class",
          data: { controller: "modal", action: "click->modal#close" },
          aria: { label: "Dialog", hidden: "false" }
        )
      end

      it "does not mutate original defaults hash" do
        component = component_class.new
        defaults = { class: "base", data: { controller: "modal" } }
        original_defaults = defaults.deep_dup

        component.deep_merge_attributes(
          defaults,
          { class: "custom", data: { action: "click" } }
        )

        expect(defaults).to eq(original_defaults)
      end

      it "handles nil overrides" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { id: "test", class: "base" },
          { role: nil }
        )

        expect(result[:role]).to be_nil
      end

      it "handles replacing nested hash with non-hash value" do
        component = component_class.new

        result = component.deep_merge_attributes(
          { data: { controller: "modal" } },
          { data: "string-value" }
        )

        expect(result[:data]).to eq("string-value")
      end
    end
  end

  describe "integration with ViewComponent" do
    it "works when included in a component" do
      component = component_class.new(id: "test", role: "button")

      expect(component).to respond_to(:html_attributes_string)
      expect(component).to respond_to(:attributes_for_rendering)
      expect(component).to respond_to(:deep_merge_attributes)
    end

    it "makes methods private by default" do
      component_with_private = Class.new(ViewComponent::Base) do
        include HtmlAttributesRendering

        def initialize(**html_attributes)
          @html_attributes = html_attributes
        end
      end.new

      expect(component_with_private.private_methods).to include(:html_attributes_string)
      expect(component_with_private.private_methods).to include(:attributes_for_rendering)
      expect(component_with_private.private_methods).to include(:deep_merge_attributes)
    end
  end
end
