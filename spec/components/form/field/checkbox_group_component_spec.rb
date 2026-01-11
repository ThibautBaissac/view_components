# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::CheckboxGroupComponent, type: :component do
  describe "initialization" do
    it "initializes with name and options" do
      component = described_class.new(name: "interests[]", options: [ "Reading", "Sports" ])

      expect(component).to be_a(described_class)
    end

    it "defaults options to empty array" do
      component = described_class.new(name: "interests[]")

      expect(component.instance_variable_get(:@options)).to eq([])
    end

    it "accepts layout parameter" do
      component = described_class.new(name: "interests[]", options: [], layout: :inline)

      expect(component.instance_variable_get(:@layout)).to eq(:inline)
    end

    it "defaults layout to stacked" do
      component = described_class.new(name: "interests[]", options: [])

      expect(component.instance_variable_get(:@layout)).to eq(:stacked)
    end

    it "accepts include_hidden parameter" do
      component = described_class.new(name: "interests[]", options: [], include_hidden: true)

      expect(component.instance_variable_get(:@include_hidden)).to be true
    end

    it "defaults include_hidden to false" do
      component = described_class.new(name: "interests[]", options: [])

      expect(component.instance_variable_get(:@include_hidden)).to be false
    end

    it "converts value to array of strings" do
      component = described_class.new(name: "interests[]", options: [], value: [ 1, 2, "3" ])

      expect(component.instance_variable_get(:@value)).to eq([ "1", "2", "3" ])
    end

    it "converts single value to array" do
      component = described_class.new(name: "interests[]", options: [], value: "reading")

      expect(component.instance_variable_get(:@value)).to eq([ "reading" ])
    end
  end

  describe "layout validation" do
    it "accepts stacked layout" do
      expect {
        described_class.new(name: "interests[]", options: [], layout: :stacked)
      }.not_to raise_error
    end

    it "accepts inline layout" do
      expect {
        described_class.new(name: "interests[]", options: [], layout: :inline)
      }.not_to raise_error
    end

    it "raises error for invalid layout" do
      expect {
        described_class.new(name: "interests[]", options: [], layout: :invalid)
      }.to raise_error(ArgumentError, /Invalid layout: invalid/)
    end

    it "includes valid layouts in error message" do
      expect {
        described_class.new(name: "interests[]", options: [], layout: :bad)
      }.to raise_error(ArgumentError, /stacked, inline/)
    end
  end

  describe "#normalized_options" do
    it "normalizes simple string array" do
      component = described_class.new(name: "interests[]", options: [ "Reading", "Sports" ])

      expect(component.normalized_options).to eq([
        [ "Reading", "Reading" ],
        [ "Sports", "Sports" ]
      ])
    end

    it "normalizes label-value pairs" do
      component = described_class.new(name: "interests[]", options: [
        [ "Read Books", "reading" ],
        [ "Play Sports", "sports" ]
      ])

      expect(component.normalized_options).to eq([
        [ "Read Books", "reading" ],
        [ "Play Sports", "sports" ]
      ])
    end

    it "converts all values to strings" do
      component = described_class.new(name: "numbers[]", options: [ 1, 2, 3 ])

      expect(component.normalized_options).to eq([
        [ "1", "1" ],
        [ "2", "2" ],
        [ "3", "3" ]
      ])
    end
  end

  describe "#selected?" do
    it "returns true when value is in array" do
      component = described_class.new(name: "interests[]", options: [], value: [ "reading", "sports" ])

      expect(component.selected?("reading")).to be true
      expect(component.selected?("sports")).to be true
    end

    it "returns false when value is not in array" do
      component = described_class.new(name: "interests[]", options: [], value: [ "reading" ])

      expect(component.selected?("sports")).to be false
    end

    it "returns false when no value set" do
      component = described_class.new(name: "interests[]", options: [])

      expect(component.selected?("reading")).to be false
    end

    it "handles string/integer comparison" do
      component = described_class.new(name: "numbers[]", options: [], value: [ "2", "3" ])

      expect(component.selected?(2)).to be true
      expect(component.selected?(1)).to be false
    end
  end

  describe "#checkbox_id" do
    it "generates unique id with index" do
      component = described_class.new(name: "interests[]", id: "user_interests", options: [])

      expect(component.checkbox_id(0)).to eq("user_interests_0")
      expect(component.checkbox_id(1)).to eq("user_interests_1")
    end
  end

  describe "#inline_layout?" do
    it "returns true when layout is inline" do
      component = described_class.new(name: "interests[]", options: [], layout: :inline)

      expect(component.inline_layout?).to be true
    end

    it "returns false when layout is stacked" do
      component = described_class.new(name: "interests[]", options: [], layout: :stacked)

      expect(component.inline_layout?).to be false
    end
  end

  describe "#stacked_layout?" do
    it "returns true when layout is stacked" do
      component = described_class.new(name: "interests[]", options: [], layout: :stacked)

      expect(component.stacked_layout?).to be true
    end

    it "returns false when layout is inline" do
      component = described_class.new(name: "interests[]", options: [], layout: :inline)

      expect(component.stacked_layout?).to be false
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders fieldset element" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ]))

        expect(page).to have_css('fieldset')
      end

      it "renders legend when label provided" do
        render_inline(described_class.new(name: "interests[]", label: "Interests", options: [ "Reading" ]))

        expect(page).to have_css('legend', text: "Interests")
      end

      it "does not render legend when no label" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading" ]))

        expect(page).not_to have_css('legend')
      end

      it "renders checkbox for each option" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports", "Music" ]))

        expect(page).to have_css('input[type="checkbox"]', count: 3)
      end

      it "renders checkbox with correct name" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ]))

        expect(page).to have_css('input[name="interests[]"]', count: 2)
      end

      it "renders checkbox with correct values" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ]))

        expect(page).to have_css('input[value="Reading"]')
        expect(page).to have_css('input[value="Sports"]')
      end

      it "renders labels for each checkbox" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ]))

        expect(page).to have_css('label', text: "Reading")
        expect(page).to have_css('label', text: "Sports")
      end

      it "generates unique ids for each checkbox" do
        render_inline(described_class.new(name: "interests[]", id: "user_interests", options: [ "Reading", "Sports" ]))

        expect(page).to have_css('input#user_interests_0')
        expect(page).to have_css('input#user_interests_1')
      end
    end

    context "with selected values" do
      it "marks selected checkboxes as checked" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [ "Reading", "Sports", "Music" ],
          value: [ "Reading", "Music" ]
        ))

        expect(page).to have_css('input[value="Reading"][checked]')
        expect(page).to have_css('input[value="Music"][checked]')
        expect(page).not_to have_css('input[value="Sports"][checked]')
      end

      it "handles label-value pairs" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [
            [ "Read Books", "reading" ],
            [ "Play Sports", "sports" ]
          ],
          value: [ "reading" ]
        ))

        expect(page).to have_css('input[value="reading"][checked]')
        expect(page).not_to have_css('input[value="sports"][checked]')
      end

      it "handles multiple selected values" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [ "A", "B", "C", "D" ],
          value: [ "A", "B", "D" ]
        ))

        expect(page).to have_css('input[checked]', count: 3)
      end
    end

    context "with stacked layout" do
      it "uses vertical spacing" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [ "Reading", "Sports" ],
          layout: :stacked
        ))

        expect(page).to have_css('.space-y-3')
      end
    end

    context "with inline layout" do
      it "uses flex layout with gaps" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [ "Reading", "Sports" ],
          layout: :inline
        ))

        expect(page).to have_css('.flex.flex-wrap.gap-4')
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading" ], hint: "Select all that apply"))

        expect(page).to have_css('p#interests-hint', text: "Select all that apply")
      end

      it "does not render hint when error present" do
        render_inline(described_class.new(
          name: "interests[]",
          options: [ "Reading" ],
          hint: "Help",
          error: "Please select at least one"
        ))

        expect(page).not_to have_css('p#interests-hint')
        expect(page).to have_css('p#interests-error')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading" ], error: "must select at least one"))

        expect(page).to have_css('p#interests-error', text: "must select at least one")
      end
    end

    context "with required field" do
      it "does not include required attribute on checkboxes" do
        # Required is set to false for individual checkboxes in a group
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ], required: true))

        expect(page).not_to have_css('input[required]')
      end

      it "renders required indicator in legend" do
        render_inline(described_class.new(
          name: "interests[]",
          label: "Interests",
          options: [ "Reading" ],
          required: true
        ))

        expect(page).to have_css('legend span.text-red-500', text: "*")
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on all checkboxes" do
        render_inline(described_class.new(name: "interests[]", options: [ "Reading", "Sports" ], disabled: true))

        expect(page).to have_css('input[disabled]', count: 2)
      end
    end

    context "with different sizes" do
      it "applies small size to legend and checkboxes" do
        render_inline(described_class.new(
          name: "interests[]",
          label: "Interests",
          options: [ "Reading" ],
          size: :small
        ))

        expect(page).to have_css('legend.text-xs')
        expect(page).to have_css('input.h-3\\.5.w-3\\.5')
      end

      it "applies medium size to legend and checkboxes" do
        render_inline(described_class.new(
          name: "interests[]",
          label: "Interests",
          options: [ "Reading" ],
          size: :medium
        ))

        expect(page).to have_css('legend.text-sm')
        expect(page).to have_css('input.h-4.w-4')
      end

      it "applies large size to legend and checkboxes" do
        render_inline(described_class.new(
          name: "interests[]",
          label: "Interests",
          options: [ "Reading" ],
          size: :large
        ))

        expect(page).to have_css('legend.text-base')
        expect(page).to have_css('input.h-5.w-5')
      end
    end
  end

  describe "accessibility" do
    it "uses fieldset for grouping" do
      render_inline(described_class.new(name: "interests[]", options: [ "Reading" ]))

      expect(page).to have_css('fieldset')
    end

    it "uses legend for group label" do
      render_inline(described_class.new(name: "interests[]", label: "Interests", options: [ "Reading" ]))

      expect(page).to have_css('legend', text: "Interests")
    end

    it "associates each label with checkbox via for attribute" do
      render_inline(described_class.new(name: "interests[]", id: "user_interests", options: [ "Reading" ]))

      expect(page).to have_css('label[for="user_interests_0"]')
      expect(page).to have_css('input#user_interests_0')
    end

    it "includes aria-describedby on fieldset for hint" do
      render_inline(described_class.new(name: "interests[]", options: [ "Reading" ], hint: "Select all"))

      # Hint should be present
      expect(page).to have_css('p#interests-hint')
    end

    it "includes aria-describedby on fieldset for error" do
      render_inline(described_class.new(name: "interests[]", options: [ "Reading" ], error: "Invalid"))

      # Error should be present
      expect(page).to have_css('p#interests-error')
    end

    it "error has role alert" do
      render_inline(described_class.new(name: "interests[]", options: [ "Reading" ], error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(
        name: "interests[]",
        label: "Interests",
        options: [ "Reading" ],
        required: true
      ))

      expect(page).to have_css('legend span[aria-hidden="true"]', text: "*")
    end

    it "adds aria-required attribute to fieldset when required" do
      render_inline(described_class.new(
        name: "interests[]",
        label: "Interests",
        options: [ "Reading" ],
        required: true
      ))

      expect(page).to have_css('fieldset[aria-required="true"]')
    end

    it "does not add aria-required attribute when not required" do
      render_inline(described_class.new(
        name: "interests[]",
        label: "Interests",
        options: [ "Reading" ],
        required: false
      ))

      expect(page).not_to have_css('fieldset[aria-required]')
    end
  end

  describe "custom HTML attributes" do
    it "renders flattened nested data attributes" do
      render_inline(described_class.new(
        name: "interests[]",
        options: [ "Reading" ],
        data: {
          controller: "checkbox-group",
          action: "click->checkbox-group#toggle"
        }
      ))

      expect(page).to have_css('fieldset[data-controller="checkbox-group"]')
      expect(page).to have_css('fieldset[data-action="click->checkbox-group#toggle"]')
    end

    it "renders custom class attribute" do
      render_inline(described_class.new(
        name: "interests[]",
        options: [ "Reading" ],
        class: "custom-class"
      ))

      expect(page).to have_css('fieldset.custom-class')
    end
  end

  describe "edge cases" do
    it "handles empty options array" do
      render_inline(described_class.new(name: "interests[]", options: []))

      expect(page).to have_css('fieldset')
      expect(page).not_to have_css('input[type="checkbox"]')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[preferences][interests][]",
        options: [ "Reading" ]
      ))

      expect(page).to have_css('input[name="user[preferences][interests][]"]')
    end

    it "handles special characters in options" do
      render_inline(described_class.new(
        name: "interests[]",
        options: [ "Reading <script>alert('xss')</script>" ]
      ))

      expect(page).to have_text("Reading")
      expect(page).not_to have_css("script")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[interests][]",
        id: "custom_interests",
        options: [
          [ "Read Books", "reading" ],
          [ "Play Sports", "sports" ],
          [ "Listen to Music", "music" ]
        ],
        value: [ "reading", "music" ],
        label: "Your Interests",
        hint: "Select all that apply",
        error: "must select at least one",
        required: true,
        disabled: false,
        size: :large,
        layout: :inline,
        include_hidden: false
      ))

      expect(page).to have_css('fieldset')
      expect(page).to have_css('legend', text: "Your Interests")
      expect(page).to have_css('legend span.text-red-500', text: "*")
      expect(page).to have_css('input[type="checkbox"]', count: 3)
      expect(page).to have_css('input[value="reading"][checked]')
      expect(page).to have_css('input[value="music"][checked]')
      expect(page).not_to have_css('input[value="sports"][checked]')
      expect(page).to have_css('p#custom_interests-error', text: "must select at least one")
      expect(page).not_to have_css('p#custom_interests-hint')
      expect(page).to have_css('.flex.flex-wrap.gap-4')
    end
  end
end
