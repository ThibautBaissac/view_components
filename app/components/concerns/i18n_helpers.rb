# frozen_string_literal: true

# I18nHelpers
#
# Provides consistent I18n helper methods for ViewComponents.
# Ensures all translations have proper fallbacks to prevent missing translation errors.
#
# @example Usage in a component
#   class MyComponent < ViewComponent::Base
#     include I18nHelpers
#
#     def button_text
#       t_component("button_text", default: "Click me")
#     end
#   end
#
module I18nHelpers
  extend ActiveSupport::Concern

  private

  # Translate a key within the component's I18n scope with automatic fallback.
  #
  # This method automatically scopes translations to "components.<component_name>.<key>"
  # and ensures a default value is always provided to prevent MissingTranslation errors.
  #
  # @param key [String, Symbol] The translation key
  # @param default [String] The default value if translation is missing (required)
  # @param options [Hash] Additional I18n options (count, scope, etc.)
  # @return [String] The translated string or default value
  #
  # @example Basic usage
  #   t_component("title", default: "Default Title")
  #   # Looks for: components.my_component.title
  #
  # @example With interpolation
  #   t_component("greeting", default: "Hello %{name}", name: user.name)
  #
  # @example With count
  #   t_component("items", count: 5, default: "%{count} items")
  #
  def t_component(key, default:, **options)
    scope = component_i18n_scope
    I18n.t(key, **options.merge(scope: scope, default: default))
  rescue I18n::MissingTranslationData
    # Fallback to default if translation is still missing
    default
  end

  # Get the I18n scope for the current component.
  # Converts class name like "Display::BadgeComponent" to "components.display.badge"
  #
  # @return [String] The I18n scope path
  def component_i18n_scope
    parts = self.class.name.split("::")
    parts.shift if parts.first == "Components" # Remove "Components" if present
    parts[-1] = parts.last.underscore.sub(/_component$/, "") # Convert BadgeComponent to badge
    [ "components", *parts.map(&:underscore) ].join(".")
  end

  # Translate a key with explicit scope and default.
  # More flexible than t_component but still ensures default is provided.
  #
  # @param key [String, Symbol] The translation key
  # @param scope [String, Symbol, Array] The I18n scope
  # @param default [String] The default value if translation is missing (required)
  # @param options [Hash] Additional I18n options
  # @return [String] The translated string or default value
  #
  # @example Usage
  #   t_with_fallback("common.cancel", scope: "components", default: "Cancel")
  #
  def t_with_fallback(key, scope:, default:, **options)
    I18n.t(key, **options.merge(scope: scope, default: default))
  rescue I18n::MissingTranslationData
    default
  end

  # Check if a translation exists for the given key.
  #
  # @param key [String, Symbol] The translation key
  # @param scope [String, Symbol, Array, nil] Optional scope
  # @return [Boolean] true if translation exists
  def translation_exists?(key, scope: nil)
    I18n.exists?(key, scope: scope)
  end
end
