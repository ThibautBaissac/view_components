# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::LanguageSwitcherComponent, type: :component do
  describe "initialization" do
    it "uses current I18n.locale by default" do
      I18n.with_locale(:fr) do
        component = described_class.new
        expect(component.instance_variable_get(:@current_locale)).to eq("fr")
      end
    end

    it "accepts custom current_locale parameter" do
      component = described_class.new(current_locale: :en)
      expect(component.instance_variable_get(:@current_locale)).to eq("en")
    end

    it "converts current_locale symbol to string" do
      component = described_class.new(current_locale: :fr)
      expect(component.instance_variable_get(:@current_locale)).to eq("fr")
    end
  end

  describe "#available_locales" do
    before do
      allow(I18n).to receive(:available_locales).and_return([ :en, :fr ])
    end

    it "returns array of locale hashes" do
      component = described_class.new(current_locale: :en)
      locales = component.available_locales

      expect(locales).to be_an(Array)
      expect(locales.size).to eq(2)
    end

    it "includes locale code, name, flag, and current keys" do
      component = described_class.new(current_locale: :en)
      locale = component.available_locales.first

      expect(locale).to have_key(:code)
      expect(locale).to have_key(:name)
      expect(locale).to have_key(:flag)
      expect(locale).to have_key(:current)
    end

    it "marks current locale with current: true" do
      component = described_class.new(current_locale: :fr)
      locales = component.available_locales

      current_locale = locales.find { |l| l[:current] }
      expect(current_locale[:code]).to eq("fr")
    end

    it "marks non-current locales with current: false" do
      component = described_class.new(current_locale: :en)
      locales = component.available_locales

      non_current = locales.find { |l| !l[:current] }
      expect(non_current).to be_present
      expect(non_current[:current]).to be false
    end

    it "memoizes the result" do
      component = described_class.new(current_locale: :en)

      first_call = component.available_locales
      second_call = component.available_locales

      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe "#current_locale_data" do
    before do
      allow(I18n).to receive(:available_locales).and_return([ :en, :fr ])
    end

    it "returns the current locale hash" do
      component = described_class.new(current_locale: :fr)
      current = component.current_locale_data

      expect(current[:code]).to eq("fr")
      expect(current[:current]).to be true
    end

    it "returns nil when no current locale found" do
      component = described_class.new(current_locale: :de)
      allow(I18n).to receive(:available_locales).and_return([ :en, :fr ])

      current = component.current_locale_data
      expect(current).to be_nil
    end
  end

  describe "#locale_name" do
    it "returns English for :en" do
      component = described_class.new
      expect(component.locale_name(:en)).to eq("English")
    end

    it "returns Français for :fr" do
      component = described_class.new
      expect(component.locale_name(:fr)).to eq("Français")
    end

    it "returns Deutsch for :de" do
      component = described_class.new
      expect(component.locale_name(:de)).to eq("Deutsch")
    end

    it "returns Español for :es" do
      component = described_class.new
      expect(component.locale_name(:es)).to eq("Español")
    end

    it "returns Italiano for :it" do
      component = described_class.new
      expect(component.locale_name(:it)).to eq("Italiano")
    end

    it "returns uppercase code for unknown locale" do
      component = described_class.new
      expect(component.locale_name(:unknown)).to eq("UNKNOWN")
    end

    it "accepts string locale" do
      component = described_class.new
      expect(component.locale_name("en")).to eq("English")
    end
  end

  describe "#locale_flag" do
    it "returns flag-gb IconComponent for :en" do
      component = described_class.new
      flag = component.locale_flag(:en)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("flag-gb")
    end

    it "returns flag-fr IconComponent for :fr" do
      component = described_class.new
      flag = component.locale_flag(:fr)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("flag-fr")
    end

    it "returns flag-de IconComponent for :de" do
      component = described_class.new
      flag = component.locale_flag(:de)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("flag-de")
    end

    it "returns flag-es IconComponent for :es" do
      component = described_class.new
      flag = component.locale_flag(:es)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("flag-es")
    end

    it "returns flag-it IconComponent for :it" do
      component = described_class.new
      flag = component.locale_flag(:it)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("flag-it")
    end

    it "returns globe-alt IconComponent for unknown locale" do
      component = described_class.new
      flag = component.locale_flag(:unknown)

      expect(flag).to be_a(Foundation::IconComponent)
      expect(flag.instance_variable_get(:@name)).to eq("globe-alt")
    end

    it "sets size to small for all flags" do
      component = described_class.new
      flag = component.locale_flag(:en)

      expect(flag.instance_variable_get(:@size)).to eq(:small)
    end

    it "uses custom set for country flags" do
      component = described_class.new
      flag = component.locale_flag(:fr)

      expect(flag.instance_variable_get(:@set)).to eq(:custom)
    end
  end

  describe "#locale_url" do
    let(:component) { described_class.new }
    let(:request_double) { instance_double(ActionDispatch::Request) }
    let(:helpers_double) { double("helpers") }

    before do
      allow(component).to receive(:helpers).and_return(helpers_double)
      allow(helpers_double).to receive(:request).and_return(request_double)
    end

    it "preserves current path" do
      allow(request_double).to receive(:path).and_return("/events")
      allow(request_double).to receive(:query_parameters).and_return({})

      url = component.locale_url(:fr)
      expect(url).to eq("/events?locale=fr")
    end

    it "preserves existing query parameters" do
      allow(request_double).to receive(:path).and_return("/events")
      allow(request_double).to receive(:query_parameters).and_return({ "page" => "2", "sort" => "name" })

      url = component.locale_url(:fr)
      expect(url).to include("page=2")
      expect(url).to include("sort=name")
      expect(url).to include("locale=fr")
    end

    it "replaces existing locale parameter" do
      allow(request_double).to receive(:path).and_return("/events")
      allow(request_double).to receive(:query_parameters).and_return({ "locale" => "en", "page" => "2" })

      url = component.locale_url(:fr)
      expect(url).to include("locale=fr")
      expect(url).not_to include("locale=en")
      expect(url).to include("page=2")
    end

    it "handles paths without query parameters" do
      allow(request_double).to receive(:path).and_return("/")
      allow(request_double).to receive(:query_parameters).and_return({})

      url = component.locale_url(:fr)
      expect(url).to eq("/?locale=fr")
    end

    it "falls back gracefully when request unavailable" do
      allow(component).to receive(:helpers).and_raise(StandardError)

      url = component.locale_url(:fr)
      expect(url).to eq("/?locale=fr")
    end

    it "accepts symbol locale" do
      allow(request_double).to receive(:path).and_return("/")
      allow(request_double).to receive(:query_parameters).and_return({})

      url = component.locale_url(:fr)
      expect(url).to include("locale=fr")
    end
  end

  describe "rendering" do
    before do
      allow(I18n).to receive(:available_locales).and_return([ :en, :fr ])
    end

    it "renders without errors" do
      expect {
        render_inline(described_class.new(current_locale: :en))
      }.not_to raise_error
    end

    it "uses DropdownMenuComponent" do
      render_inline(described_class.new(current_locale: :en))

      # DropdownMenuComponent should be rendered
      expect(page).to have_css("div[role='menu']", visible: :all)
    end
  end

  describe "HTML options" do
    before do
      allow(I18n).to receive(:available_locales).and_return([ :en, :fr ])
    end

    it "accepts custom class" do
      component = described_class.new(current_locale: :en, class: "custom-language-switcher")
      expect(component.instance_variable_get(:@html_options)[:class]).to eq("custom-language-switcher")
    end

    it "accepts custom data attributes" do
      component = described_class.new(
        current_locale: :en,
        data: { testid: "language-switcher" }
      )
      expect(component.instance_variable_get(:@html_options)[:data]).to eq({ testid: "language-switcher" })
    end
  end
end
