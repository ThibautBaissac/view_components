# frozen_string_literal: true

# @label Form::Field::DatePicker
# @logical_path Form/Field
# @note
#   A flexible date picker component that wraps a native HTML date input
#   with consistent styling, labels, hints, error handling, and accessibility features.
#   Supports min/max date constraints, clearable option, and custom sizes.
class Form::Field::DatePickerComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   The input will use the native browser date picker.
  def default
    render(Form::Field::DatePickerComponent.new(name: "date"))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the date picker field.
  #   The label is automatically associated with the input for accessibility.
  def with_label
    render(Form::Field::DatePickerComponent.new(
      name: "birth_date",
      label: "Date of Birth"
    ))
  end

  # @label With Placeholder
  # @note
  #   Placeholders provide hints about the expected input format.
  #   Note: Browser support for placeholder on date inputs varies.
  def with_placeholder
    render(Form::Field::DatePickerComponent.new(
      name: "event_date",
      label: "Event Date",
      placeholder: "Select a date"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the input.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::DatePickerComponent.new(
      name: "appointment",
      label: "Appointment Date",
      hint: "Choose a date for your appointment."
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::DatePickerComponent.new(
      name: "deadline",
      label: "Deadline",
      required: true,
      hint: "This field is required."
    ))
  end

  # @label With Preset Value
  # @note
  #   Pre-populate the date picker with a specific date value.
  #   The value can be a Date object, Time, or ISO string.
  def with_value
    render(Form::Field::DatePickerComponent.new(
      name: "start_date",
      label: "Start Date",
      value: Date.today
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The input is marked as invalid for screen readers.
  def with_error
    render(Form::Field::DatePickerComponent.new(
      name: "due_date",
      label: "Due Date",
      value: Date.today - 7,
      error: "must be in the future"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::DatePickerComponent.new(
      name: "meeting_date",
      label: "Meeting Date",
      error: [ "must be a weekday", "must be within business hours" ]
    ))
  end

  # @label With Min Constraint
  # @note
  #   Set a minimum selectable date. Dates before this will be disabled.
  def with_min
    render(Form::Field::DatePickerComponent.new(
      name: "future_date",
      label: "Future Date",
      min: Date.today,
      hint: "Only future dates can be selected."
    ))
  end

  # @label With Max Constraint
  # @note
  #   Set a maximum selectable date. Dates after this will be disabled.
  def with_max
    render(Form::Field::DatePickerComponent.new(
      name: "past_date",
      label: "Past Date",
      max: Date.today,
      hint: "Only past dates can be selected."
    ))
  end

  # @label With Date Range
  # @note
  #   Combine min and max to create a selectable date range.
  def with_date_range
    render(Form::Field::DatePickerComponent.new(
      name: "booking_date",
      label: "Booking Date",
      min: Date.today,
      max: Date.today + 30.days,
      hint: "Select a date within the next 30 days."
    ))
  end

  # @label With Step
  # @note
  #   Use step to allow only specific day intervals (e.g., weekly selection).
  def with_step
    render(Form::Field::DatePickerComponent.new(
      name: "weekly_date",
      label: "Weekly Meeting Date",
      min: Date.today,
      step: 7,
      hint: "Select a date (weekly intervals only)."
    ))
  end

  # @label Clearable
  # @note
  #   Add a clear button to allow users to easily reset the date value.
  #   Uses Stimulus controller for enhanced interactivity.
  def clearable
    render(Form::Field::DatePickerComponent.new(
      name: "optional_date",
      label: "Optional Date",
      clearable: true,
      value: Date.today,
      hint: "Click the X button to clear the date."
    ))
  end

  # @label Small Size
  # @note
  #   A compact version for space-constrained layouts.
  def small_size
    render(Form::Field::DatePickerComponent.new(
      name: "date",
      label: "Small Date Picker",
      size: :small,
      value: Date.today
    ))
  end

  # @label Medium Size
  # @note
  #   The default size for most use cases.
  def medium_size
    render(Form::Field::DatePickerComponent.new(
      name: "date",
      label: "Medium Date Picker",
      size: :medium,
      value: Date.today
    ))
  end

  # @label Large Size
  # @note
  #   A larger version for improved touch targets or emphasis.
  def large_size
    render(Form::Field::DatePickerComponent.new(
      name: "date",
      label: "Large Date Picker",
      size: :large,
      value: Date.today
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled date pickers cannot be interacted with.
  def disabled
    render(Form::Field::DatePickerComponent.new(
      name: "locked_date",
      label: "Locked Date",
      value: Date.today,
      disabled: true,
      hint: "This date cannot be changed."
    ))
  end

  # @label Readonly State
  # @note
  #   Readonly date pickers display their value but cannot be edited.
  def readonly
    render(Form::Field::DatePickerComponent.new(
      name: "readonly_date",
      label: "Readonly Date",
      value: Date.today,
      readonly: true,
      hint: "This date is for display only."
    ))
  end

  # @label With Leading Icon
  # @note
  #   Add a custom icon to the left of the input for visual context.
  def with_leading_icon
    render(Form::Field::DatePickerComponent.new(
      name: "calendar_date",
      label: "Event Date"
    )) do |component|
      component.with_icon_leading do
        render(Foundation::IconComponent.new(name: "calendar", size: :small))
      end
    end
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, hint, constraints, and clearable option.
  def complete_example
    render(Form::Field::DatePickerComponent.new(
      name: "appointment_date",
      label: "Appointment Date",
      min: Date.today,
      max: Date.today + 60.days,
      clearable: true,
      required: true,
      hint: "Select an available appointment slot within the next 60 days."
    ))
  end

  # @label Form Context
  # @note
  #   Example of multiple date pickers in a form context.
  def form_context
    render_with_template
  end
end
