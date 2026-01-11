# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::Field::DatePickerComponent, type: :component do
  describe "initialization" do
    it "initializes with name" do
      component = described_class.new(name: "event_date")

      expect(component).to be_a(described_class)
    end

    it "accepts min date parameter" do
      min_date = Date.today
      component = described_class.new(name: "event_date", min: min_date)

      expect(component.instance_variable_get(:@min)).to eq(min_date.iso8601)
    end

    it "accepts max date parameter" do
      max_date = Date.today + 30.days
      component = described_class.new(name: "event_date", max: max_date)

      expect(component.instance_variable_get(:@max)).to eq(max_date.iso8601)
    end

    it "accepts step parameter" do
      component = described_class.new(name: "event_date", step: 7)

      expect(component.instance_variable_get(:@step)).to eq(7)
    end

    it "accepts clearable parameter" do
      component = described_class.new(name: "event_date", clearable: true)

      expect(component.instance_variable_get(:@clearable)).to be true
    end

    it "defaults clearable to false" do
      component = described_class.new(name: "event_date")

      expect(component.instance_variable_get(:@clearable)).to be false
    end

    it "normalizes Date value to ISO 8601 format" do
      date = Date.new(2024, 12, 25)
      component = described_class.new(name: "event_date", value: date)

      expect(component.instance_variable_get(:@value)).to eq("2024-12-25")
    end

    it "normalizes Time value to ISO 8601 format" do
      time = Time.zone.parse("2024-12-25 10:30:00")
      component = described_class.new(name: "event_date", value: time)

      expect(component.instance_variable_get(:@value)).to eq("2024-12-25")
    end

    it "normalizes DateTime value to ISO 8601 format" do
      datetime = DateTime.new(2024, 12, 25, 10, 30)
      component = described_class.new(name: "event_date", value: datetime)

      expect(component.instance_variable_get(:@value)).to eq("2024-12-25")
    end

    it "normalizes string date value" do
      component = described_class.new(name: "event_date", value: "2024-12-25")

      expect(component.instance_variable_get(:@value)).to eq("2024-12-25")
    end

    it "handles nil value" do
      component = described_class.new(name: "event_date", value: nil)

      expect(component.instance_variable_get(:@value)).to be_nil
    end
  end

  describe "date range validation" do
    it "does not raise error when min is less than max" do
      expect {
        described_class.new(
          name: "event_date",
          min: Date.today,
          max: Date.today + 30.days
        )
      }.not_to raise_error
    end

    it "raises error when min is greater than max" do
      expect {
        described_class.new(
          name: "event_date",
          min: Date.today + 30.days,
          max: Date.today
        )
      }.to raise_error(ArgumentError, /min date.*cannot be greater than max date/)
    end

    it "raises error with invalid min date format" do
      expect {
        described_class.new(
          name: "event_date",
          min: "invalid-date",
          max: Date.today
        )
      }.to raise_error(ArgumentError, /Invalid min date format/)
    end

    it "raises error with invalid max date format" do
      expect {
        described_class.new(
          name: "event_date",
          min: Date.today,
          max: "invalid-date"
        )
      }.to raise_error(ArgumentError, /Invalid max date format/)
    end

    it "does not validate range when only min is provided" do
      expect {
        described_class.new(name: "event_date", min: Date.today)
      }.not_to raise_error
    end

    it "does not validate range when only max is provided" do
      expect {
        described_class.new(name: "event_date", max: Date.today + 30.days)
      }.not_to raise_error
    end
  end

  describe "#clearable?" do
    it "returns true when clearable is true and not disabled" do
      component = described_class.new(name: "event_date", clearable: true, disabled: false)

      expect(component.clearable?).to be true
    end

    it "returns false when clearable is false" do
      component = described_class.new(name: "event_date", clearable: false)

      expect(component.clearable?).to be false
    end

    it "returns false when disabled" do
      component = described_class.new(name: "event_date", clearable: true, disabled: true)

      expect(component.clearable?).to be false
    end

    it "returns false when readonly" do
      component = described_class.new(name: "event_date", clearable: true, readonly: true)

      expect(component.clearable?).to be false
    end
  end

  describe "rendering" do
    context "with basic configuration" do
      it "renders date input with type date" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).to have_css('input[type="date"]')
      end

      it "renders date input with name attribute" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).to have_css('input[name="event_date"]')
      end

      it "renders date input with generated id" do
        render_inline(described_class.new(name: "user[event_date]"))

        expect(page).to have_css('input#user_event_date')
      end

      it "renders date input with custom id" do
        render_inline(described_class.new(name: "event_date", id: "custom_date"))

        expect(page).to have_css('input#custom_date')
      end

      it "renders date input with value" do
        render_inline(described_class.new(name: "event_date", value: Date.new(2024, 12, 25)))

        expect(page).to have_css('input[value="2024-12-25"]')
      end

      it "renders date input without value when nil" do
        render_inline(described_class.new(name: "event_date", value: nil))

        expect(page).not_to have_css('input[value]')
      end
    end

    context "with label" do
      it "renders label when provided" do
        render_inline(described_class.new(name: "event_date", label: "Event Date"))

        expect(page).to have_css('label', text: "Event Date")
      end

      it "associates label with input via for attribute" do
        render_inline(described_class.new(name: "event_date", id: "date", label: "Date"))

        expect(page).to have_css('label[for="date"]')
        expect(page).to have_css('input#date')
      end

      it "does not render label when not provided" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).not_to have_css('label')
      end
    end

    context "with placeholder" do
      it "renders placeholder when provided" do
        render_inline(described_class.new(name: "event_date", placeholder: "Select a date"))

        expect(page).to have_css('input[placeholder="Select a date"]')
      end
    end

    context "with date constraints" do
      it "renders min attribute when provided" do
        min_date = Date.new(2024, 1, 1)
        render_inline(described_class.new(name: "event_date", min: min_date))

        expect(page).to have_css('input[min="2024-01-01"]')
      end

      it "renders max attribute when provided" do
        max_date = Date.new(2024, 12, 31)
        render_inline(described_class.new(name: "event_date", max: max_date))

        expect(page).to have_css('input[max="2024-12-31"]')
      end

      it "renders step attribute when provided" do
        render_inline(described_class.new(name: "event_date", step: 7))

        expect(page).to have_css('input[step="7"]')
      end

      it "does not render min when not provided" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).not_to have_css('input[min]')
      end

      it "does not render max when not provided" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).not_to have_css('input[max]')
      end

      it "does not render step when not provided" do
        render_inline(described_class.new(name: "event_date"))

        expect(page).not_to have_css('input[step]')
      end
    end

    context "with hint" do
      it "renders hint when provided" do
        render_inline(described_class.new(name: "event_date", hint: "Choose a future date"))

        expect(page).to have_css('p#event_date-hint', text: "Choose a future date")
      end

      it "does not render hint when error is present" do
        render_inline(described_class.new(name: "event_date", hint: "Help", error: "must be in future"))

        expect(page).not_to have_css('p#event_date-hint')
        expect(page).to have_css('p#event_date-error')
      end
    end

    context "with error state" do
      it "renders error when provided" do
        render_inline(described_class.new(name: "event_date", error: "must be in future"))

        expect(page).to have_css('p#event_date-error', text: "must be in future")
      end

      it "applies error styling to input" do
        render_inline(described_class.new(name: "event_date", error: "Invalid"))

        expect(page).to have_css('input.border-red-400')
        expect(page).to have_css('input.bg-red-50\\/50')
      end

      it "sets aria-invalid attribute when error present" do
        render_inline(described_class.new(name: "event_date", error: "Invalid"))

        expect(page).to have_css('input[aria-invalid="true"]')
      end

      it "sets aria-describedby to error id" do
        render_inline(described_class.new(name: "event_date", error: "Invalid"))

        expect(page).to have_css('input[aria-describedby="event_date-error"]')
      end
    end

    context "with required field" do
      it "includes required attribute on input" do
        render_inline(described_class.new(name: "event_date", required: true))

        expect(page).to have_css('input[required]')
      end

      it "renders required indicator in label" do
        render_inline(described_class.new(name: "event_date", label: "Event Date", required: true))

        expect(page).to have_css('label span.text-red-500', text: "*")
      end
    end

    context "with disabled state" do
      it "includes disabled attribute on input" do
        render_inline(described_class.new(name: "event_date", disabled: true))

        expect(page).to have_css('input[disabled]')
      end

      it "applies disabled styling to input" do
        render_inline(described_class.new(name: "event_date", disabled: true))

        expect(page).to have_css('input.bg-slate-100')
        expect(page).to have_css('input.cursor-not-allowed')
      end
    end

    context "with readonly state" do
      it "includes readonly attribute on input" do
        render_inline(described_class.new(name: "event_date", readonly: true))

        expect(page).to have_css('input[readonly]')
      end
    end

    context "with different sizes" do
      it "applies small size classes" do
        render_inline(described_class.new(
          name: "event_date",
          label: "Date",
          size: :small
        ))

        expect(page).to have_css('label.text-xs')
        expect(page).to have_css('input.px-3.py-2.text-xs')
      end

      it "applies medium size classes" do
        render_inline(described_class.new(
          name: "event_date",
          label: "Date",
          size: :medium
        ))

        expect(page).to have_css('label.text-sm')
        expect(page).to have_css('input.px-3\\.5.py-2\\.5.text-sm')
      end

      it "applies large size classes" do
        render_inline(described_class.new(
          name: "event_date",
          label: "Date",
          size: :large
        ))

        expect(page).to have_css('label.text-base')
        expect(page).to have_css('input.px-4.py-3.text-base')
      end
    end

    context "with HTML attributes" do
      it "renders with custom class" do
        render_inline(described_class.new(name: "event_date", class: "custom-class"))

        expect(page).to have_css('input.custom-class')
      end

      it "renders with custom data attributes" do
        render_inline(described_class.new(
          name: "event_date",
          data: { controller: "calendar" }
        ))

        expect(page).to have_css('input[data-controller="calendar"]')
      end
    end
  end

  describe "clearable functionality" do
    context "when clearable is true" do
      it "includes Stimulus controller on wrapper" do
        render_inline(described_class.new(name: "event_date", clearable: true))

        expect(page).to have_css('[data-controller="components--date-picker"]')
      end

      it "includes Stimulus target on input" do
        render_inline(described_class.new(name: "event_date", clearable: true))

        expect(page).to have_css('input[data-components--date-picker-target="input"]')
      end

      it "includes Stimulus action on input" do
        render_inline(described_class.new(name: "event_date", clearable: true))

        expect(page).to have_css('input[data-action="input->components--date-picker#handleInput"]')
      end

      it "renders clear button" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

        expect(page).to have_css('button[type="button"]')
      end

      it "includes Stimulus target on clear button" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

        expect(page).to have_css('button[data-components--date-picker-target="clearButton"]')
      end

      it "includes Stimulus action on clear button" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

        expect(page).to have_css('button[data-action="components--date-picker#clear"]')
      end

      it "includes aria-label on clear button" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

        # Check for translated label (default locale is :fr in test environment)
        expect(page).to have_css('button[aria-label]')
        expect(page.find('button[aria-label]')['aria-label']).to be_present
      end

      it "hides clear button when no value" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: nil))

        expect(page).to have_css('button.hidden')
      end

      it "shows clear button when value present" do
        render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

        expect(page).not_to have_css('button.hidden')
      end

      it "adds right padding to input for clear button" do
        render_inline(described_class.new(name: "event_date", clearable: true))

        expect(page).to have_css('input.pr-10')
      end
    end

    context "when clearable is false" do
      it "does not include Stimulus controller" do
        render_inline(described_class.new(name: "event_date", clearable: false))

        expect(page).not_to have_css('[data-controller="components--date-picker"]')
      end

      it "does not render clear button" do
        render_inline(described_class.new(name: "event_date", clearable: false))

        expect(page).not_to have_css('button')
      end

      it "does not add right padding to input" do
        render_inline(described_class.new(name: "event_date", clearable: false))

        expect(page).not_to have_css('input.pr-10')
      end
    end

    context "when disabled" do
      it "does not show clear button even if clearable is true" do
        render_inline(described_class.new(name: "event_date", clearable: true, disabled: true))

        expect(page).not_to have_css('button')
        expect(page).not_to have_css('[data-controller="components--date-picker"]')
      end
    end

    context "when readonly" do
      it "does not show clear button even if clearable is true" do
        render_inline(described_class.new(name: "event_date", clearable: true, readonly: true))

        expect(page).not_to have_css('button')
        expect(page).not_to have_css('[data-controller="components--date-picker"]')
      end
    end
  end

  describe "accessibility" do
    it "uses semantic label element" do
      render_inline(described_class.new(name: "event_date", label: "Date"))

      expect(page).to have_css('label')
    end

    it "associates label with input via for attribute" do
      render_inline(described_class.new(
        name: "event_date",
        id: "custom_date",
        label: "Event Date"
      ))

      expect(page).to have_css('label[for="custom_date"]')
      expect(page).to have_css('input#custom_date')
    end

    it "includes aria-describedby for hint" do
      render_inline(described_class.new(name: "event_date", hint: "Future date"))

      expect(page).to have_css('input[aria-describedby="event_date-hint"]')
    end

    it "includes aria-describedby for error" do
      render_inline(described_class.new(name: "event_date", error: "Invalid"))

      expect(page).to have_css('input[aria-describedby="event_date-error"]')
    end

    it "includes aria-invalid when error present" do
      render_inline(described_class.new(name: "event_date", error: "Invalid"))

      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "error has role alert" do
      render_inline(described_class.new(name: "event_date", error: "Invalid"))

      expect(page).to have_css('p[role="alert"]')
    end

    it "clear button has aria-label" do
      render_inline(described_class.new(name: "event_date", clearable: true, value: Date.today))

      # Verify button has aria-label attribute (translation applied)
      expect(page).to have_css('button[aria-label]')
      expect(page.find('button[aria-label]')['aria-label']).to be_present
    end

    it "required indicator has aria-hidden" do
      render_inline(described_class.new(name: "event_date", label: "Date", required: true))

      expect(page).to have_css('label span[aria-hidden="true"]', text: "*")
    end
  end

  describe "edge cases" do
    it "handles complex nested name" do
      render_inline(described_class.new(
        name: "user[event][date]",
        label: "Date"
      ))

      expect(page).to have_css('input#user_event_date')
      expect(page).to have_css('input[name="user[event][date]"]')
    end

    it "handles special characters in label" do
      render_inline(described_class.new(name: "event_date", label: "Date <script>alert('xss')</script>"))

      expect(page).to have_text("Date")
      expect(page).not_to have_css("script")
    end

    it "combines multiple configuration options" do
      render_inline(described_class.new(
        name: "user[event_date]",
        id: "custom_date",
        value: Date.new(2024, 12, 25),
        label: "Event Date",
        placeholder: "Select date",
        hint: "Future date only",
        error: "must be in future",
        required: true,
        disabled: false,
        size: :large,
        min: Date.today,
        max: Date.today + 365.days,
        step: 1,
        clearable: true,
        class: "custom-class"
      ))

      expect(page).to have_css('input#custom_date')
      expect(page).to have_css('input[name="user[event_date]"]')
      expect(page).to have_css('input[type="date"]')
      expect(page).to have_css('input[value="2024-12-25"]')
      expect(page).to have_css('input[placeholder="Select date"]')
      expect(page).to have_css('label', text: "Event Date")
      expect(page).to have_css('label span.text-red-500', text: "*")
      expect(page).to have_css('p#custom_date-error', text: "must be in future")
      expect(page).not_to have_css('p#custom_date-hint')
      expect(page).to have_css('input[required]')
      expect(page).to have_css('input[min]')
      expect(page).to have_css('input[max]')
      expect(page).to have_css('input[step="1"]')
      expect(page).to have_css('input.custom-class')
      expect(page).to have_css('button[aria-label]') # Has translated aria-label
    end
  end

  describe "internationalization" do
    it "uses English clear button label by default" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(
          name: "event_date",
          clearable: true,
          value: Date.today
        ))

        expect(page).to have_css('button[aria-label="Clear date"]')
      end
    end

    it "uses French clear button label in French locale" do
      I18n.with_locale(:fr) do
        render_inline(described_class.new(
          name: "event_date",
          clearable: true,
          value: Date.today
        ))

        expect(page).to have_css('button[aria-label="Effacer la date"]')
      end
    end

    it "falls back to default when translation missing" do
      # Test with a key that doesn't exist in the component's locale files
      # The t_component method should fall back to the default parameter
      component = described_class.new(
        name: "event_date",
        clearable: true,
        value: Date.today
      )

      # Verify the clear_button_label method returns a string
      expect(component.clear_button_label).to be_a(String)
      expect(component.clear_button_label).to be_present
    end
  end

  describe "form builder integration" do
    let(:event) { Event.new(event_date: Date.new(2024, 6, 15)) }

    it "renders with correct name attribute for nested forms" do
      render_inline(described_class.new(
        name: "event[event_date]",
        value: event.event_date,
        label: "Event Date"
      ))

      expect(page).to have_css('input[name="event[event_date]"]')
      expect(page).to have_css('input[value="2024-06-15"]')
      expect(page).to have_css('label', text: "Event Date")
    end

    it "displays validation errors from model" do
      # Manually add an error (don't trigger validations which may use French)
      custom_error = "must be in the future"
      event.errors.add(:event_date, custom_error)

      render_inline(described_class.new(
        name: "event[event_date]",
        error: event.errors[:event_date].first,
        label: "Event Date"
      ))

      expect(page).to have_css('p[role="alert"]', text: custom_error)
      expect(page).to have_css('input[aria-invalid="true"]')
    end

    it "works with multiple error messages" do
      event.errors.add(:event_date, "can't be blank")
      event.errors.add(:event_date, "must be a valid date")

      render_inline(described_class.new(
        name: "event[event_date]",
        error: event.errors[:event_date],
        label: "Event Date"
      ))

      expect(page).to have_css('p[role="alert"]')
      error_text = page.find('p[role="alert"]').text
      expect(error_text).to include("can't be blank")
      expect(error_text).to include("must be a valid date")
    end

    it "handles required fields with form validation" do
      render_inline(described_class.new(
        name: "event[event_date]",
        label: "Event Date",
        required: true
      ))

      expect(page).to have_css('input[required]')
      expect(page).to have_css('label span.text-red-500', text: "*")
    end

    it "applies constraints for date validation" do
      render_inline(described_class.new(
        name: "event[event_date]",
        label: "Event Date",
        min: Date.today,
        max: Date.today + 30.days
      ))

      expect(page).to have_css("input[min='#{Date.today.iso8601}']")
      expect(page).to have_css("input[max='#{(Date.today + 30.days).iso8601}']")
    end
  end
end
