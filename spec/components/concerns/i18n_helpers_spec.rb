# frozen_string_literal: true

require "rails_helper"

RSpec.describe I18nHelpers, type: :concern do
  # Create dummy component classes to test the concern
  let(:component_class) do
    stub_const("TestComponent", Class.new(ViewComponent::Base) do
      include I18nHelpers

      # Make private methods accessible for testing
      public :t_component, :component_i18n_scope, :t_with_fallback, :translation_exists?
    end)
  end

  let(:nested_component_class) do
    stub_const("Display::BadgeComponent", Class.new(ViewComponent::Base) do
      include I18nHelpers
      public :t_component, :component_i18n_scope
    end)
  end

  let(:components_namespaced_class) do
    stub_const("Components::Feedback::AlertComponent", Class.new(ViewComponent::Base) do
      include I18nHelpers
      public :component_i18n_scope
    end)
  end

  let(:component) { component_class.new }

  describe "#component_i18n_scope" do
    it "converts simple component name to scope" do
      simple_class = stub_const("ButtonComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :component_i18n_scope
      end)

      expect(simple_class.new.component_i18n_scope).to eq("components.button")
    end

    it "converts nested component name to scope" do
      nested_class = stub_const("Foundation::ButtonComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :component_i18n_scope
      end)

      expect(nested_class.new.component_i18n_scope).to eq("components.foundation.button")
    end

    it "removes Components namespace if present" do
      expect(components_namespaced_class.new.component_i18n_scope).to eq("components.feedback.alert")
    end

    it "removes _component suffix from class name" do
      expect(nested_component_class.new.component_i18n_scope).to eq("components.display.badge")
    end

    it "converts camelCase to snake_case" do
      camel_class = stub_const("MyCustomWidgetComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :component_i18n_scope
      end)

      expect(camel_class.new.component_i18n_scope).to eq("components.my_custom_widget")
    end

    it "handles deeply nested namespaces" do
      deep_class = stub_const("Admin::Settings::UI::FormComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :component_i18n_scope
      end)

      expect(deep_class.new.component_i18n_scope).to eq("components.admin.settings.ui.form")
    end
  end

  describe "#t_component" do
    context "with existing translations" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            button: {
              submit: "Submit",
              cancel: "Cancel"
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "returns translation when it exists" do
        button_class = stub_const("ButtonComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end)

        result = button_class.new.t_component("submit", default: "Default Submit")

        expect(result).to eq("Submit")
      end

      it "uses component's automatic scope" do
        button_class = stub_const("ButtonComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end)

        result = button_class.new.t_component("cancel", default: "Default Cancel")

        expect(result).to eq("Cancel")
      end
    end

    context "with missing translations" do
      it "returns default value when translation missing" do
        test_comp = stub_const("MissingTranslationComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end).new

        result = test_comp.t_component("missing_key", default: "Default Value")

        expect(result).to eq("Default Value")
      end

      it "requires default parameter" do
        expect {
          component.t_component("some_key")
        }.to raise_error(ArgumentError, /missing keyword.*default/)
      end

      it "rescues MissingTranslationData and returns default" do
        test_comp = stub_const("ErrorHandlingComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end).new

        allow(I18n).to receive(:t).and_raise(I18n::MissingTranslationData.new(:en, "test.key"))

        result = test_comp.t_component("key", default: "Fallback")

        expect(result).to eq("Fallback")
      end
    end

    context "with interpolation" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            button: {
              greeting: "Hello %{name}"
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "supports interpolation variables" do
        button_class = stub_const("ButtonComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end)

        result = button_class.new.t_component("greeting", default: "Hi %{name}", name: "Alice")

        expect(result).to eq("Hello Alice")
      end

      it "uses default with interpolation when translation missing" do
        test_comp = stub_const("InterpolationComponent", Class.new(ViewComponent::Base) do
          include I18nHelpers
          public :t_component
        end).new

        result = test_comp.t_component("welcome", default: "Welcome %{name}", name: "Bob")

        expect(result).to eq("Welcome Bob")
      end
    end

    context "with count option" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            display: {
              badge: {
                items: {
                  one: "1 item",
                  other: "%{count} items"
                }
              }
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "supports count option for pluralization" do
        result_singular = nested_component_class.new.t_component("items", count: 1, default: "%{count} item(s)")
        result_plural = nested_component_class.new.t_component("items", count: 5, default: "%{count} item(s)")

        expect(result_singular).to eq("1 item")
        expect(result_plural).to eq("5 items")
      end
    end

    context "with nested component scopes" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            display: {
              badge: {
                title: "Badge Title"
              }
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "resolves translations in nested scope" do
        result = nested_component_class.new.t_component("title", default: "Default Title")

        expect(result).to eq("Badge Title")
      end
    end
  end

  describe "#t_with_fallback" do
    context "with existing translations" do
      before do
        I18n.backend.store_translations(:en, {
          common: {
            cancel: "Cancel",
            submit: "Submit"
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "returns translation when it exists" do
        result = component.t_with_fallback("cancel", scope: "common", default: "Default Cancel")

        expect(result).to eq("Cancel")
      end

      it "supports explicit scope" do
        result = component.t_with_fallback("submit", scope: "common", default: "Default Submit")

        expect(result).to eq("Submit")
      end
    end

    context "with missing translations" do
      it "returns default value when translation missing" do
        result = component.t_with_fallback("missing", scope: "nonexistent", default: "Fallback")

        expect(result).to eq("Fallback")
      end

      it "requires both scope and default parameters" do
        expect {
          component.t_with_fallback("key")
        }.to raise_error(ArgumentError, /missing keyword.*scope/)

        expect {
          component.t_with_fallback("key", scope: "test")
        }.to raise_error(ArgumentError, /missing keyword.*default/)
      end

      it "rescues MissingTranslationData and returns default" do
        allow(I18n).to receive(:t).and_raise(I18n::MissingTranslationData.new(:en, "test.key"))

        result = component.t_with_fallback("key", scope: "test", default: "Fallback")

        expect(result).to eq("Fallback")
      end
    end

    context "with interpolation" do
      before do
        I18n.backend.store_translations(:en, {
          messages: {
            greeting: "Hello %{name}"
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "supports interpolation variables" do
        result = component.t_with_fallback("greeting", scope: "messages", default: "Hi", name: "Alice")

        expect(result).to eq("Hello Alice")
      end
    end

    context "with array scope" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            common: {
              buttons: {
                save: "Save"
              }
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "supports array scope syntax" do
        result = component.t_with_fallback("save", scope: [ :components, :common, :buttons ], default: "Default Save")

        expect(result).to eq("Save")
      end
    end
  end

  describe "#translation_exists?" do
    before do
      I18n.backend.store_translations(:en, {
        components: {
          button: {
            submit: "Submit"
          }
        },
        common: {
          cancel: "Cancel"
        }
      })
    end

    after do
      I18n.backend.reload!
    end

    context "without scope" do
      it "returns true for existing translation" do
        result = component.translation_exists?("common.cancel")

        expect(result).to be true
      end

      it "returns false for missing translation" do
        result = component.translation_exists?("nonexistent.key")

        expect(result).to be false
      end
    end

    context "with scope" do
      it "returns true for existing translation in scope" do
        result = component.translation_exists?("submit", scope: "components.button")

        expect(result).to be true
      end

      it "returns false for missing translation in scope" do
        result = component.translation_exists?("missing", scope: "components.button")

        expect(result).to be false
      end

      it "supports array scope syntax" do
        result = component.translation_exists?("submit", scope: [ :components, :button ])

        expect(result).to be true
      end
    end
  end

  describe "integration with ViewComponent" do
    it "works when included in a component" do
      expect(component).to respond_to(:t_component)
      expect(component).to respond_to(:component_i18n_scope)
      expect(component).to respond_to(:t_with_fallback)
      expect(component).to respond_to(:translation_exists?)
    end

    it "makes methods private by default" do
      component_with_private = Class.new(ViewComponent::Base) do
        include I18nHelpers
      end.new

      expect(component_with_private.private_methods).to include(:t_component)
      expect(component_with_private.private_methods).to include(:component_i18n_scope)
      expect(component_with_private.private_methods).to include(:t_with_fallback)
      expect(component_with_private.private_methods).to include(:translation_exists?)
    end
  end

  describe "real-world usage patterns" do
    let(:modal_component) do
      stub_const("Layout::ModalComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers

        def initialize(title: nil)
          @title = title
        end

        def modal_title
          @title || t_component("default_title", default: "Modal")
        end

        public :modal_title
      end)
    end

    context "with component instance" do
      before do
        I18n.backend.store_translations(:en, {
          components: {
            layout: {
              modal: {
                default_title: "Dialog Window",
                close_button: "Close",
                confirm_button: "Confirm"
              }
            }
          }
        })
      end

      after do
        I18n.backend.reload!
      end

      it "uses translation when available" do
        component = modal_component.new

        expect(component.modal_title).to eq("Dialog Window")
      end

      it "allows overriding with explicit value" do
        component = modal_component.new(title: "Custom Title")

        expect(component.modal_title).to eq("Custom Title")
      end
    end

    context "without translations" do
      it "falls back to default values" do
        component = modal_component.new

        expect(component.modal_title).to eq("Modal")
      end
    end
  end

  describe "error handling and edge cases" do
    it "raises error for empty string keys" do
      test_comp = stub_const("EdgeCaseComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :t_component
      end).new

      # I18n raises ArgumentError for empty string keys
      expect {
        test_comp.t_component("", default: "Empty Key")
      }.to raise_error(I18n::ArgumentError)
    end

    it "handles symbol keys" do
      test_comp = stub_const("SymbolKeyComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :t_component
      end).new

      result = test_comp.t_component(:symbol_key, default: "Symbol Default")

      expect(result).to eq("Symbol Default")
    end

    it "handles keys with special characters" do
      before_translations = {
        components: {
          test: {
            "key-with-dashes" => "Dashed Key"
          }
        }
      }

      I18n.backend.store_translations(:en, before_translations)

      test_class = stub_const("TestComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :t_component
      end)

      result = test_class.new.t_component("key-with-dashes", default: "Default")

      expect(result).to eq("Dashed Key")

      I18n.backend.reload!
    end

    it "handles nil default gracefully" do
      test_comp = stub_const("NilDefaultComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :t_component
      end).new

      # This should not raise an error - nil is a valid default
      expect {
        test_comp.t_component("key", default: nil)
      }.not_to raise_error
    end

    it "preserves HTML safety of translations" do
      I18n.backend.store_translations(:en, {
        components: {
          test: {
            html_content: "<b>Bold</b>".html_safe
          }
        }
      })

      test_class = stub_const("TestComponent", Class.new(ViewComponent::Base) do
        include I18nHelpers
        public :t_component
      end)

      result = test_class.new.t_component("html_content", default: "Default")

      expect(result).to eq("<b>Bold</b>")

      I18n.backend.reload!
    end
  end
end
