# frozen_string_literal: true

# Form::Field::DatePickerComponent
#
# A flexible date picker component that wraps a native HTML date input element
# with consistent styling, labels, hints, and error handling. Integrates with
# Stimulus for enhanced functionality like clear button and format display.
#
# @example Basic usage
#   <%= render Form::Field::DatePickerComponent.new(name: "birth_date") %>
#
# @example With label
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "birth_date",
#     label: "Date of Birth"
#   ) %>
#
# @example With placeholder and hint
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "event_date",
#     label: "Event Date",
#     placeholder: "Select a date",
#     hint: "Choose the date for your event."
#   ) %>
#
# @example With min and max constraints
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "appointment",
#     label: "Appointment Date",
#     min: Date.today,
#     max: Date.today + 30.days,
#     hint: "Available dates are within the next 30 days."
#   ) %>
#
# @example With preset value
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "start_date",
#     label: "Start Date",
#     value: Date.today
#   ) %>
#
# @example With error state
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "due_date",
#     label: "Due Date",
#     error: "must be in the future"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "deadline",
#     label: "Deadline",
#     required: true
#   ) %>
#
# @example With clearable option
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "optional_date",
#     label: "Optional Date",
#     clearable: true,
#     value: Date.today
#   ) %>
#
# @example Disabled state
#   <%= render Form::Field::DatePickerComponent.new(
#     name: "locked_date",
#     value: Date.today,
#     disabled: true
#   ) %>
#
class Form::Field::DatePickerComponent < Form::Field::BaseComponent
  # Slot for icon leading (optional, e.g., calendar icon)
  renders_one :icon_leading

  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param value [Date, Time, DateTime, String] The input value (Date object, Time, DateTime, or ISO string)
  # @param label [String] The label text
  # @param placeholder [String] The placeholder text
  # @param hint [String] Help text displayed below the input
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly
  # @param size [Symbol] The input size (:small, :medium, :large)
  # @param min [Date, String] Minimum selectable date
  # @param max [Date, String] Maximum selectable date
  # @param step [Integer, String] Step interval in days (e.g., 1, 7)
  # @param clearable [Boolean] Whether to show a clear button
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    min: nil,
    max: nil,
    step: nil,
    clearable: false,
    **options
  )
    super(name: name, **options)
    @min = normalize_date(min)
    @max = normalize_date(max)
    @step = step
    @clearable = clearable
    @value = normalize_date(@value)

    validate_date_range!
  end

  # Whether the component is clearable
  # @return [Boolean]
  def clearable?
    @clearable && !@disabled && !@readonly
  end

  # Translated clear button label
  # Uses I18nHelpers concern to fetch locale-specific translation
  # @return [String] The translated "Clear date" label
  def clear_button_label
    t_component("clear_button_label", default: "Clear date")
  end

  private

  # Normalize date to ISO 8601 string format (YYYY-MM-DD)
  # @param date [Date, String, nil] The date to normalize
  # @return [String, nil] ISO 8601 date string or nil
  def normalize_date(date)
    return nil if date.blank?

    case date
    when Date, Time, DateTime
      date.to_date.iso8601
    when String
      # If it's already a string, try to parse and normalize it
      Date.parse(date).iso8601
    else
      date.to_s
    end
  rescue ArgumentError
    # If parsing fails, return the original value
    date.to_s
  end

  # Validate that min is not greater than max
  # @raise [ArgumentError] if min > max or if dates are invalid
  def validate_date_range!
    return if @min.blank? || @max.blank?

    begin
      min_date = Date.parse(@min)
    rescue ArgumentError => e
      raise ArgumentError, "Invalid min date format: #{@min} (#{e.message})"
    end

    begin
      max_date = Date.parse(@max)
    rescue ArgumentError => e
      raise ArgumentError, "Invalid max date format: #{@max} (#{e.message})"
    end

    if min_date > max_date
      raise ArgumentError, "min date (#{@min}) cannot be greater than max date (#{@max})"
    end
  end

  # CSS classes for the input wrapper
  # @return [String]
  def input_wrapper_classes
    "relative"
  end

  # CSS classes for the input element
  # @return [String]
  def input_classes
    classes = [
      base_field_classes,
      size_field_classes,
      state_field_classes,
      "date-picker-input"
    ]
    classes << "pl-10" if icon_leading?
    classes << "pr-10" if clearable?
    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  # CSS classes for icon wrapper
  # @param position [Symbol] :leading or :trailing
  # @return [String]
  def icon_wrapper_classes(position)
    base = "absolute inset-y-0 flex items-center"
    case position
    when :leading
      "#{base} left-0 pl-3 pointer-events-none"
    when :trailing
      "#{base} right-0 pr-3"
    end
  end

  # Icon color based on state
  # @return [String]
  def icon_color_classes
    if has_error?
      "text-red-400"
    elsif @disabled
      "text-gray-300"
    else
      "text-gray-400"
    end
  end

  # Build the input attributes hash
  # @return [Hash]
  def input_attributes
    attrs = base_field_attributes.merge(
      type: "date",
      value: @value
    )
    attrs[:min] = @min if @min.present?
    attrs[:max] = @max if @max.present?
    attrs[:step] = @step if @step.present?
    merge_html_attributes(attrs)
  end

  # Merged input attributes including CSS classes and data attributes
  # @return [Hash]
  def merged_input_attributes
    attrs = input_attributes.merge(class: input_classes)

    # Add Stimulus data attributes if clearable
    if clearable?
      attrs[:data] ||= {}
      attrs[:data]["components--date-picker-target"] = "input"
      attrs[:data][:action] = "input->components--date-picker#handleInput"
    end

    attrs
  end

  # Wrapper data attributes hash for Stimulus
  # @return [Hash]
  def wrapper_data_attributes
    return {} unless clearable?

    { data: { controller: "components--date-picker" } }
  end
end
