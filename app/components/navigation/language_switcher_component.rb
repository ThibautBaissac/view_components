# frozen_string_literal: true

module Navigation
  # Language Switcher Component
  #
  # A dropdown menu for switching between available application locales.
  # Uses DropdownMenuComponent for consistent behavior and accessibility.
  # Displays current locale with flag icon and allows selection from available languages.
  #
  # @example Basic usage
  #   <%= render Navigation::LanguageSwitcherComponent.new %>
  #
  # @example With specific locale
  #   <%= render Navigation::LanguageSwitcherComponent.new(current_locale: :fr) %>
  #
  # @example With custom HTML attributes
  #   <%= render Navigation::LanguageSwitcherComponent.new(
  #     current_locale: :en,
  #     class: "custom-class",
  #     data: { test_id: "language-switcher" }
  #   ) %>
  #
  class LanguageSwitcherComponent < ViewComponent::Base
    include I18nHelpers

    # @param current_locale [Symbol, String] The currently active locale (default: I18n.locale)
    # @param html_options [Hash] Additional HTML attributes for the wrapper element
    def initialize(current_locale: I18n.locale, **html_options)
      @current_locale = current_locale.to_s
      @html_options = html_options
    end

    # Returns the current locale data
    # @return [Hash] Hash with :code, :name, :flag keys
    def current_locale_data
      available_locales.find { |locale| locale[:current] }
    end

    # Returns all available locales with metadata
    # @return [Array<Hash>] Array of locale hashes with :code, :name, :flag, :current keys
    def available_locales
      @available_locales ||= I18n.available_locales.map do |locale|
        {
          code: locale.to_s,
          name: locale_name(locale),
          flag: locale_flag(locale),
          current: locale.to_s == @current_locale
        }
      end
    end

    # Returns the URL for switching to a specific locale
    # @param locale [String, Symbol] The locale code
    # @return [String]
    def locale_url(locale)
      # Preserve current path and just change locale parameter
      current_params = helpers.request.query_parameters.except("locale")
      current_path = helpers.request.path

      if current_params.any?
        "#{current_path}?#{current_params.merge(locale: locale).to_query}"
      else
        "#{current_path}?locale=#{locale}"
      end
    rescue StandardError
      # Fallback for tests or when request is not available
      "/?locale=#{locale}"
    end

    # Returns the human-readable name for a locale
    # @param locale [Symbol, String] The locale code
    # @return [String] The locale's display name
    def locale_name(locale)
      case locale.to_sym
      when :en then "English"
      when :fr then "Français"
      when :de then "Deutsch"
      when :es then "Español"
      when :it then "Italiano"
      else locale.to_s.upcase
      end
    end

    # Returns the flag icon component for a locale
    # @param locale [Symbol, String] The locale code
    # @return [Foundation::IconComponent] The flag icon component
    def locale_flag(locale)
      case locale.to_sym
      when :en
        Foundation::IconComponent.new(name: "flag-gb", set: :custom, size: :small)
      when :fr
        Foundation::IconComponent.new(name: "flag-fr", set: :custom, size: :small)
      when :de
        Foundation::IconComponent.new(name: "flag-de", set: :custom, size: :small)
      when :es
        Foundation::IconComponent.new(name: "flag-es", set: :custom, size: :small)
      when :it
        Foundation::IconComponent.new(name: "flag-it", set: :custom, size: :small)
      else
        Foundation::IconComponent.new(name: "globe-alt", size: :small)
      end
    end
  end
end
