# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::MultiSelectComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "tags[]")

      expect(component).to be_a(described_class)
    end

    it "accepts options array" do
      component = described_class.new(name: "tags[]", options: [ "Ruby", "Rails" ])

      expect(component.instance_variable_get(:@options)).to eq([ "Ruby", "Rails" ])
    end

    it "accepts placeholder parameter" do
      component = described_class.new(name: "tags[]", placeholder: "Search...")

      expect(component.instance_variable_get(:@placeholder)).to eq("Search...")
    end

    it "defaults options to empty array" do
      component = described_class.new(name: "tags[]")

      expect(component.instance_variable_get(:@options)).to eq([])
    end

    it "defaults placeholder to French translation" do
      component = described_class.new(name: "tags[]")

      expect(component.instance_variable_get(:@placeholder)).to eq("Rechercher...")
    end

    it "coerces value to array" do
      component = described_class.new(name: "tags[]", value: "Ruby")

      expect(component.instance_variable_get(:@value)).to eq([ "Ruby" ])
    end

    it "keeps array value as array" do
      component = described_class.new(name: "tags[]", value: [ "Ruby", "Rails" ])

      expect(component.instance_variable_get(:@value)).to eq([ "Ruby", "Rails" ])
    end

    it "coerces nil value to empty array" do
      component = described_class.new(name: "tags[]", value: nil)

      expect(component.instance_variable_get(:@value)).to eq([])
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders wrapper div with form-field class" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css("div.form-field")
      end

      it "renders Stimulus controller container" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-controller="components--multi-select"]')
      end

      it "renders hidden inputs for form submission" do
        render_inline(described_class.new(
          name: "tags[]",
          value: [ "Ruby", "Rails" ]
        ))

        expect(page).to have_css('input[type="hidden"][name="tags[]"][value="Ruby"]', visible: :all)
        expect(page).to have_css('input[type="hidden"][name="tags[]"][value="Rails"]', visible: :all)
      end

      it "renders label when provided" do
        render_inline(described_class.new(name: "tags[]", label: "Tags"))

        expect(page).to have_css('label[for="tags"]', text: "Tags")
      end

      it "renders hint when provided" do
        render_inline(described_class.new(name: "tags[]", hint: "Select all that apply"))

        expect(page).to have_css('p#tags-hint', text: "Select all that apply")
      end

      it "renders error when provided" do
        render_inline(described_class.new(name: "tags[]", error: "must select at least one"))

        expect(page).to have_css('p#tags-error[role="alert"]', text: "must select at least one")
      end

      it "renders error instead of hint when both present" do
        render_inline(described_class.new(name: "tags[]", hint: "Help", error: "Invalid"))

        expect(page).to have_css('p#tags-error')
        expect(page).not_to have_css('p#tags-hint')
      end
    end

    context "with trigger button" do
      it "renders combobox trigger element" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[role="combobox"][aria-haspopup="listbox"]')
      end

      it "renders trigger with aria-expanded attribute" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[role="combobox"][aria-expanded="false"]')
      end

      it "renders trigger with tabindex for keyboard focus" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[role="combobox"][tabindex="0"]')
      end

      it "renders trigger with -1 tabindex when disabled" do
        render_inline(described_class.new(name: "tags[]", disabled: true))

        expect(page).to have_css('[role="combobox"][tabindex="-1"]')
      end
    end

    context "with simple options array" do
      it "renders options as both label and value" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby", "Rails", "JavaScript" ]
        ))

        expect(page).to have_css('[role="option"][data-value="Ruby"]', text: "Ruby")
        expect(page).to have_css('[role="option"][data-value="Rails"]', text: "Rails")
        expect(page).to have_css('[role="option"][data-value="JavaScript"]', text: "JavaScript")
      end

      it "renders correct number of options" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby", "Rails" ]
        ))

        expect(page).to have_css('[role="option"]', count: 2)
      end
    end

    context "with label-value pairs" do
      it "renders options with custom labels and values" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ [ "Ruby Programming", "ruby" ], [ "Ruby on Rails", "rails" ] ]
        ))

        expect(page).to have_css('[role="option"][data-value="ruby"]', text: "Ruby Programming")
        expect(page).to have_css('[role="option"][data-value="rails"]', text: "Ruby on Rails")
      end

      it "stores both label and value in data attributes" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ [ "Ruby Programming", "ruby" ] ]
        ))

        expect(page).to have_css('[data-value="ruby"][data-label="Ruby Programming"]')
      end
    end

    context "with grouped options" do
      it "renders group labels" do
        render_inline(described_class.new(
          name: "technologies[]",
          options: {
            "Backend" => [ [ "Ruby", "ruby" ], [ "Python", "python" ] ],
            "Frontend" => [ [ "JavaScript", "js" ], [ "TypeScript", "ts" ] ]
          }
        ))

        expect(page).to have_css("div.uppercase", text: "Backend")
        expect(page).to have_css("div.uppercase", text: "Frontend")
      end

      it "renders options within groups" do
        render_inline(described_class.new(
          name: "technologies[]",
          options: {
            "Backend" => [ [ "Ruby", "ruby" ], [ "Python", "python" ] ]
          }
        ))

        expect(page).to have_css('[role="option"][data-value="ruby"]', text: "Ruby")
        expect(page).to have_css('[role="option"][data-value="python"]', text: "Python")
      end
    end

    context "with selected values" do
      it "renders selected items as tags" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby", "Rails", "JavaScript" ],
          value: [ "Ruby", "Rails" ]
        ))

        expect(page).to have_css('[data-components--multi-select-target="tag"]', count: 2)
      end

      it "marks options as selected with aria-selected" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby", "Rails" ],
          value: [ "Ruby" ]
        ))

        expect(page).to have_css('[role="option"][data-value="Ruby"][aria-selected="true"]')
        expect(page).to have_css('[role="option"][data-value="Rails"][aria-selected="false"]')
      end

      it "renders tag with label text" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ [ "Ruby Programming", "ruby" ] ],
          value: [ "ruby" ]
        ))

        expect(page).to have_css('[data-components--multi-select-target="tag"]', text: "Ruby Programming")
      end

      it "renders tag with remove button" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby" ],
          value: [ "Ruby" ]
        ))

        expect(page).to have_css('[data-components--multi-select-target="tag"] button[aria-label="Retirer Ruby"]')
      end

      it "hides placeholder when items selected" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby" ],
          value: [ "Ruby" ],
          placeholder: "Search..."
        ))

        expect(page).to have_css('[data-components--multi-select-target="placeholder"].hidden')
      end
    end

    context "with placeholder" do
      it "renders placeholder text" do
        render_inline(described_class.new(
          name: "tags[]",
          placeholder: "Select tags..."
        ))

        expect(page).to have_css('[data-components--multi-select-target="placeholder"]', text: "Select tags...")
      end

      it "shows placeholder when no items selected" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby" ],
          placeholder: "Search..."
        ))

        expect(page).not_to have_css('[data-components--multi-select-target="placeholder"].hidden')
      end
    end

    context "with search input" do
      it "renders search input in dropdown" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-components--multi-select-target="input"]')
      end

      it "renders search input with placeholder" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('input[placeholder="Rechercher des options..."]')
      end

      it "renders search input with autocomplete off" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('input[autocomplete="off"]')
      end
    end

    context "with required field" do
      it "renders required indicator in label" do
        render_inline(described_class.new(
          name: "tags[]",
          label: "Tags",
          required: true
        ))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end

      it "includes required attribute on field" do
        render_inline(described_class.new(name: "tags[]", required: true))

        expect(page).to have_css('[required]')
      end
    end

    context "with disabled state" do
      it "includes disabled state in trigger" do
        render_inline(described_class.new(name: "tags[]", disabled: true))

        expect(page).to have_css('[aria-disabled="true"]')
      end

      it "applies disabled styling to trigger" do
        render_inline(described_class.new(name: "tags[]", disabled: true))

        expect(page).to have_css('[role="combobox"].cursor-not-allowed')
      end
    end

    context "with error state" do
      it "applies error styling to trigger" do
        render_inline(described_class.new(name: "tags[]", error: "Invalid"))

        expect(page).to have_css('[role="combobox"].border-red-300')
      end

      it "sets aria-invalid attribute" do
        render_inline(described_class.new(name: "tags[]", error: "Invalid"))

        expect(page).to have_css('[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "tags[]", error: "Invalid"))

        expect(page).to have_css('[aria-describedby="tags-error"]')
      end
    end

    context "with different sizes" do
      it "applies small size classes to trigger" do
        render_inline(described_class.new(
          name: "tags[]",
          label: "Tags",
          size: :small
        ))

        expect(page).to have_css('[role="combobox"].px-2\\.5.py-1\\.5.text-xs')
      end

      it "applies medium size classes to trigger" do
        render_inline(described_class.new(
          name: "tags[]",
          label: "Tags",
          size: :medium
        ))

        expect(page).to have_css('[role="combobox"].px-3.py-2.text-sm')
      end

      it "applies large size classes to trigger" do
        render_inline(described_class.new(
          name: "tags[]",
          label: "Tags",
          size: :large
        ))

        expect(page).to have_css('[role="combobox"].px-4.py-3.text-base')
      end
    end

    context "with dropdown" do
      it "renders dropdown with listbox role" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-components--multi-select-target="dropdown"][role="listbox"]')
      end

      it "renders dropdown with multiselectable attribute" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[role="listbox"][aria-multiselectable="true"]')
      end

      it "renders dropdown as hidden by default" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-components--multi-select-target="dropdown"].hidden')
      end

      it "renders no results message element" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-no-results].hidden', text: "Aucune option trouvée")
      end
    end

    context "with Stimulus integration" do
      it "includes selected value data attribute" do
        render_inline(described_class.new(
          name: "tags[]",
          value: [ "Ruby", "Rails" ]
        ))

        expect(page).to have_css('[data-components--multi-select-selected-value]')
      end

      it "includes placeholder value data attribute" do
        render_inline(described_class.new(
          name: "tags[]",
          placeholder: "Search..."
        ))

        expect(page).to have_css('[data-components--multi-select-placeholder-value="Search..."]')
      end

      it "includes data-name attribute for form submission" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-name="tags[]"]')
      end

      it "includes action for trigger click" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-action*="click->components--multi-select#toggleDropdown"]')
      end

      it "includes action for trigger keydown" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-action*="keydown->components--multi-select#handleTriggerKeydown"]')
      end

      it "includes action for search input" do
        render_inline(described_class.new(name: "tags[]"))

        expect(page).to have_css('[data-action*="input->components--multi-select#filterOptions"]')
      end

      it "includes action for option selection" do
        render_inline(described_class.new(
          name: "tags[]",
          options: [ "Ruby" ]
        ))

        expect(page).to have_css('[data-action*="click->components--multi-select#selectOption"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "tags[]", label: "Tags"))

      expect(page).to have_css("label")
    end

    it "associates label with trigger via for attribute" do
      render_inline(described_class.new(
        name: "tags[]",
        id: "user_tags",
        label: "Tags"
      ))

      expect(page).to have_css('label[for="user_tags"]')
    end

    it "associates dropdown with label via aria-labelledby" do
      render_inline(described_class.new(
        name: "tags[]",
        label: "Tags"
      ))

      expect(page).to have_css('[role="listbox"][aria-labelledby="tags-label"]')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "tags[]", hint: "Help"))

      expect(page).to have_css('[aria-describedby="tags-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "tags[]", error: "Invalid"))

      expect(page).to have_css('[aria-describedby="tags-error"]')
    end

    it "error has role=alert" do
      render_inline(described_class.new(name: "tags[]", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "renders tag remove buttons with accessible labels" do
      render_inline(described_class.new(
        name: "tags[]",
        options: [ "Ruby" ],
        value: [ "Ruby" ]
      ))

      expect(page).to have_css('button[aria-label="Retirer Ruby"]')
    end
  end

  describe "edge cases" do
    it "handles nil value" do
      render_inline(described_class.new(
        name: "tags[]",
        options: [ "Ruby", "Rails" ],
        value: nil
      ))

      expect(page).to have_css('[data-controller="components--multi-select"]')
      expect(page).not_to have_css('[data-components--multi-select-target="tag"]')
    end

    it "handles empty options array" do
      render_inline(described_class.new(name: "tags[]", options: []))

      expect(page).to have_css('[data-controller="components--multi-select"]')
      expect(page).not_to have_css('[role="option"]')
    end

    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[profile][tags][]",
        label: "Tags"
      ))

      expect(page).to have_css('[data-name="user[profile][tags][]"]')
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[tags][]",
        options: [ [ "Ruby Programming", "ruby" ], [ "Rails Framework", "rails" ] ],
        value: [ "rails" ],
        label: "Tags",
        placeholder: "Search technologies",
        hint: "Select all that apply",
        error: "is invalid",
        required: true,
        size: :large
      ))

      expect(page).to have_css('[data-name="user[tags][]"]')
      expect(page).to have_css('[role="option"][data-value="rails"][aria-selected="true"]')
      expect(page).to have_css("label", text: "Tags")
      expect(page).to have_css("label span", text: "*")
      expect(page).to have_css('p[role="alert"]', text: "is invalid")
      expect(page).to have_css('[role="combobox"].px-4.py-3')
    end
  end

  describe "#grouped_options?" do
    it "returns true for hash options" do
      component = described_class.new(
        name: "tags[]",
        options: { "Group" => [ [ "Option", "val" ] ] }
      )

      expect(component.grouped_options?).to eq(true)
    end

    it "returns false for array options" do
      component = described_class.new(name: "tags[]", options: [ "Option" ])

      expect(component.grouped_options?).to eq(false)
    end

    it "returns false for empty array" do
      component = described_class.new(name: "tags[]", options: [])

      expect(component.grouped_options?).to eq(false)
    end
  end

  describe "#selected?" do
    it "returns true when value is in selected array" do
      component = described_class.new(
        name: "tags[]",
        options: [ "Ruby", "Rails" ],
        value: [ "Ruby", "Rails" ]
      )

      expect(component.selected?("Ruby")).to eq(true)
    end

    it "returns false when value not in selected array" do
      component = described_class.new(
        name: "tags[]",
        options: [ "Ruby", "Rails", "JS" ],
        value: [ "Ruby" ]
      )

      expect(component.selected?("JS")).to eq(false)
    end

    it "returns false when value array is empty" do
      component = described_class.new(
        name: "tags[]",
        options: [ "Ruby" ],
        value: []
      )

      expect(component.selected?("Ruby")).to eq(false)
    end

    it "handles type coercion for comparison" do
      component = described_class.new(
        name: "ids[]",
        options: [ [ "One", 1 ] ],
        value: [ "1" ]
      )

      expect(component.selected?(1)).to eq(true)
    end
  end

  describe "#selected_options" do
    it "returns array of selected label-value pairs" do
      component = described_class.new(
        name: "tags[]",
        options: [ [ "Ruby Programming", "ruby" ], [ "Rails Framework", "rails" ] ],
        value: [ "ruby" ]
      )

      expect(component.selected_options).to eq([ [ "Ruby Programming", "ruby" ] ])
    end

    it "returns multiple selected pairs" do
      component = described_class.new(
        name: "tags[]",
        options: [ [ "Ruby", "ruby" ], [ "Rails", "rails" ], [ "JS", "js" ] ],
        value: [ "ruby", "js" ]
      )

      expect(component.selected_options).to eq([ [ "Ruby", "ruby" ], [ "JS", "js" ] ])
    end

    it "returns empty array when nothing selected" do
      component = described_class.new(
        name: "tags[]",
        options: [ "Ruby", "Rails" ],
        value: []
      )

      expect(component.selected_options).to eq([])
    end

    it "handles simple options array" do
      component = described_class.new(
        name: "tags[]",
        options: [ "Ruby", "Rails" ],
        value: [ "Ruby" ]
      )

      expect(component.selected_options).to eq([ [ "Ruby", "Ruby" ] ])
    end

    it "handles grouped options" do
      component = described_class.new(
        name: "tags[]",
        options: {
          "Backend" => [ [ "Ruby", "ruby" ], [ "Python", "python" ] ],
          "Frontend" => [ [ "JavaScript", "js" ] ]
        },
        value: [ "ruby", "js" ]
      )

      expect(component.selected_options).to eq([ [ "Ruby", "ruby" ], [ "JavaScript", "js" ] ])
    end
  end
end
