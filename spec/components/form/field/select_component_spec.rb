# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::SelectComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "country")

      expect(component).to be_a(described_class)
    end

    it "accepts options array" do
      component = described_class.new(name: "country", options: [ "USA", "Canada" ])

      expect(component.instance_variable_get(:@options)).to eq([ "USA", "Canada" ])
    end

    it "accepts prompt parameter" do
      component = described_class.new(name: "country", prompt: "Select country")

      expect(component.instance_variable_get(:@prompt)).to eq("Select country")
    end

    it "accepts include_blank parameter" do
      component = described_class.new(name: "country", include_blank: true)

      expect(component.instance_variable_get(:@include_blank)).to eq(true)
    end

    it "defaults options to empty array" do
      component = described_class.new(name: "country")

      expect(component.instance_variable_get(:@options)).to eq([])
    end

    it "defaults prompt to nil" do
      component = described_class.new(name: "country")

      expect(component.instance_variable_get(:@prompt)).to be_nil
    end

    it "defaults include_blank to false" do
      component = described_class.new(name: "country")

      expect(component.instance_variable_get(:@include_blank)).to eq(false)
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders select element with name" do
        render_inline(described_class.new(name: "country"))

        expect(page).to have_css('select[name="country"]')
      end

      it "renders select with generated id" do
        render_inline(described_class.new(name: "user[country]"))

        expect(page).to have_css('select#user_country')
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "country", label: "Country"))

        expect(page).to have_css('label[for="country"]', text: "Country")
      end

      it "renders hint when provided" do
        render_inline(described_class.new(name: "country", hint: "Select your country"))

        expect(page).to have_css('p#country-hint', text: "Select your country")
      end

      it "renders error when provided" do
        render_inline(described_class.new(name: "country", error: "must be selected"))

        expect(page).to have_css('p#country-error[role="alert"]', text: "must be selected")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(name: "country", hint: "Help", error: "Invalid"))

        expect(page).to have_css('p#country-error')
        expect(page).not_to have_css('p#country-hint')
      end
    end

    context "with simple options array" do
      it "renders options as both label and value" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA", "Canada", "Mexico" ]
        ))

        expect(page).to have_css('select option[value="USA"]', text: "USA")
        expect(page).to have_css('select option[value="Canada"]', text: "Canada")
        expect(page).to have_css('select option[value="Mexico"]', text: "Mexico")
      end

      it "renders correct number of options" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA", "Canada" ]
        ))

        expect(page).to have_css('select option', count: 2)
      end
    end

    context "with label-value pairs" do
      it "renders options with custom labels and values" do
        render_inline(described_class.new(
          name: "country",
          options: [ [ "United States", "us" ], [ "Canada", "ca" ] ]
        ))

        expect(page).to have_css('select option[value="us"]', text: "United States")
        expect(page).to have_css('select option[value="ca"]', text: "Canada")
      end
    end

    context "with grouped options" do
      it "renders optgroup elements" do
        render_inline(described_class.new(
          name: "city",
          options: {
            "North America" => [ [ "New York", "ny" ], [ "Toronto", "to" ] ],
            "Europe" => [ [ "London", "lo" ], [ "Paris", "pa" ] ]
          }
        ))

        expect(page).to have_css('select optgroup[label="North America"]')
        expect(page).to have_css('select optgroup[label="Europe"]')
      end

      it "renders options within optgroups" do
        render_inline(described_class.new(
          name: "city",
          options: {
            "North America" => [ [ "New York", "ny" ], [ "Toronto", "to" ] ]
          }
        ))

        expect(page).to have_css('optgroup[label="North America"] option[value="ny"]', text: "New York")
        expect(page).to have_css('optgroup[label="North America"] option[value="to"]', text: "Toronto")
      end
    end

    context "with selected value" do
      it "marks option as selected" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA", "Canada" ],
          value: "Canada"
        ))

        expect(page).to have_css('select option[value="Canada"][selected]')
      end

      it "handles string value matching" do
        render_inline(described_class.new(
          name: "count",
          options: [ [ "One", "1" ], [ "Two", "2" ] ],
          value: 1
        ))

        expect(page).to have_css('select option[value="1"][selected]')
      end
    end

    context "with prompt" do
      it "renders prompt as first disabled option" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA", "Canada" ],
          prompt: "Select a country"
        ))

        expect(page).to have_css('select option:first-child[disabled]', text: "Select a country")
      end

      it "renders prompt with empty value" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA" ],
          prompt: "Choose..."
        ))

        expect(page).to have_css('select option[value=""][disabled]')
      end
    end

    context "with include_blank" do
      it "renders blank option when true" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA", "Canada" ],
          include_blank: true
        ))

        expect(page).to have_css('select option[value=""]', text: "")
      end

      it "renders custom blank text when string provided" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA" ],
          include_blank: "-- None --"
        ))

        expect(page).to have_css('select option[value=""]', text: "-- None --")
      end

      it "renders blank option before other options" do
        render_inline(described_class.new(
          name: "country",
          options: [ "USA" ],
          include_blank: true
        ))

        expect(page).to have_css('select option:first-child[value=""]')
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(
          name: "country",
          label: "Country",
          required: true
        ))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on select" do
        render_inline(described_class.new(name: "country", required: true))

        expect(page).to have_css('select[required]')
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on select" do
        render_inline(described_class.new(name: "country", disabled: true))

        expect(page).to have_css('select[disabled]')
      end

      it "applies disabled styling" do
        render_inline(described_class.new(name: "country", disabled: true))

        expect(page).to have_css('select.bg-slate-100.cursor-not-allowed')
      end
    end

    context "with readonly state" do
      it "includes readonly attribute on select" do
        render_inline(described_class.new(name: "country", readonly: true))

        expect(page).to have_css('select[readonly]')
      end
    end

    context "with error state" do
      it "applies error styling to select" do
        render_inline(described_class.new(name: "country", error: "Invalid"))

        expect(page).to have_css('select.border-red-400')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "country", error: "Invalid"))

        expect(page).to have_css('select[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "country", error: "Invalid"))

        expect(page).to have_css('select[aria-describedby="country-error"]')
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "country",
          label: "Country",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('select.px-3.py-2.text-xs')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "country",
          label: "Country",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('select.px-3\\.5.py-2\\.5.text-sm')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "country",
          label: "Country",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('select.px-4.py-3.text-base')
      end

      it "renders small icon for small select" do
        component = described_class.new(name: "country", size: :small)

        expect(component.send(:icon_size)).to eq(:small)
      end

      it "renders medium icon for medium select" do
        component = described_class.new(name: "country", size: :medium)

        expect(component.send(:icon_size)).to eq(:medium)
      end

      it "renders large icon for large select" do
        component = described_class.new(name: "country", size: :large)

        expect(component.send(:icon_size)).to eq(:large)
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "country", class: "custom-class"))

        expect(page).to have_css('select.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "country",
          data: { controller: "select" }
        ))

        expect(page).to have_css('select[data-controller="select"]')
      end
    end

    context "with icon styling" do
      it "applies error color to icon when error present" do
        component = described_class.new(name: "country", error: "Invalid")

        expect(component.send(:icon_color_classes)).to include("text-red-400")
      end

      it "applies disabled color to icon when disabled" do
        component = described_class.new(name: "country", disabled: true)

        expect(component.send(:icon_color_classes)).to include("text-slate-300")
      end

      it "applies default color to icon in normal state" do
        component = described_class.new(name: "country")

        expect(component.send(:icon_color_classes)).to include("text-slate-400")
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "country", label: "Country"))

      expect(page).to have_css('label')
    end

    it "associates label with select via for attribute" do
      render_inline(described_class.new(
        name: "country",
        id: "user_country",
        label: "Country"
      ))

      expect(page).to have_css('label[for="user_country"]')
      expect(page).to have_css('select#user_country')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "country", hint: "Help"))

      expect(page).to have_css('select[aria-describedby="country-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "country", error: "Invalid"))

      expect(page).to have_css('select[aria-describedby="country-error"]')
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "country", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end
  end

  describe "edge cases" do
    it "handles nil value" do
      render_inline(described_class.new(
        name: "country",
        options: [ "USA", "Canada" ],
        value: nil
      ))

      expect(page).to have_css('select')
      expect(page).not_to have_css('option[selected]')
    end

    it "handles empty options array" do
      render_inline(described_class.new(name: "country", options: []))

      expect(page).to have_css('select')
      expect(page).not_to have_css('option')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[address][country]",
        label: "Country"
      ))

      expect(page).to have_css('select#user_address_country')
      expect(page).to have_css('select[name="user[address][country]"]')
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[country]",
        options: [ [ "United States", "us" ], [ "Canada", "ca" ] ],
        value: "ca",
        label: "Country",
        prompt: "Select a country",
        hint: "Choose your country",
        error: "is invalid",
        required: true,
        size: :large,
        class: "custom-class"
      ))

      expect(page).to have_css('select[name="user[country]"]')
      expect(page).to have_css('select option[value="ca"][selected]')
      expect(page).to have_css('label', text: "Country")
      expect(page).to have_css('label span', text: "*")
      expect(page).to have_css('p[role="alert"]', text: "is invalid")
      expect(page).to have_css('select.custom-class')
      expect(page).to have_css('select option:first-child[disabled]', text: "Select a country")
    end
  end

  describe "#grouped_options?" do
    it "returns true for hash options" do
      component = described_class.new(
        name: "city",
        options: { "Group" => [ [ "Option", "val" ] ] }
      )

      expect(component.grouped_options?).to eq(true)
    end

    it "returns false for array options" do
      component = described_class.new(name: "city", options: [ "Option" ])

      expect(component.grouped_options?).to eq(false)
    end
  end

  describe "#selected?" do
    it "returns true when values match" do
      component = described_class.new(
        name: "country",
        options: [ "USA", "Canada" ],
        value: "USA"
      )

      expect(component.selected?("USA")).to eq(true)
    end

    it "returns false when values don't match" do
      component = described_class.new(
        name: "country",
        options: [ "USA", "Canada" ],
        value: "USA"
      )

      expect(component.selected?("Canada")).to eq(false)
    end

    it "returns false when value is nil" do
      component = described_class.new(
        name: "country",
        options: [ "USA" ],
        value: nil
      )

      expect(component.selected?("USA")).to eq(false)
    end

    it "handles type coercion for comparison" do
      component = described_class.new(
        name: "count",
        options: [ [ "One", "1" ] ],
        value: 1
      )

      expect(component.selected?("1")).to eq(true)
    end
  end
end
