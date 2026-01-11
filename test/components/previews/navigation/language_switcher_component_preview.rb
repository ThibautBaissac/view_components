# frozen_string_literal: true

# @label Language Switcher
# @display bg_color "#f8fafc"
class Navigation::LanguageSwitcherComponentPreview < ViewComponent::Preview
  # Default language switcher showing current locale
  # @label Default
  def default
    render(Navigation::LanguageSwitcherComponent.new)
  end

  # Language switcher in English locale
  # @label English Locale
  def english_locale
    I18n.with_locale(:en) do
      render(Navigation::LanguageSwitcherComponent.new)
    end
  end

  # Language switcher in French locale
  # @label French Locale
  def french_locale
    I18n.with_locale(:fr) do
      render(Navigation::LanguageSwitcherComponent.new)
    end
  end

  # Language switcher in a navigation bar context
  # @label In Navigation Bar
  def in_navigation_bar
    render_with_template
  end

  # Language switcher with dark background
  # @label Dark Background
  def dark_background
    render_with_template
  end

  # Multiple language switchers showing different states
  # @label All Locales
  def all_locales
    render_with_template
  end
end
