# frozen_string_literal: true

# @label Form::Field::Select
# @logical_path Form/Field
# @note
#   A flexible select component that provides consistent styling,
#   labels, hints, error handling, and accessibility features.
#   Supports simple options, label-value pairs, grouped options,
#   prompts, include_blank, and multiple selections.
class Form::Field::SelectComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name and options array.
  #   Options can be simple strings where value equals label.
  def default
    render(Form::Field::SelectComponent.new(
      name: "country",
      options: %w[USA Canada Mexico]
    ))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the select field.
  #   The label is automatically associated with the select for accessibility.
  def with_label
    render(Form::Field::SelectComponent.new(
      name: "country",
      label: "Country",
      options: %w[USA Canada Mexico]
    ))
  end

  # @label With Prompt
  # @note
  #   Prompts provide a disabled placeholder option that guides the user.
  #   The prompt is not selectable and acts as a hint.
  def with_prompt
    render(Form::Field::SelectComponent.new(
      name: "status",
      label: "Status",
      options: %w[Active Inactive Pending],
      prompt: "Select a status..."
    ))
  end

  # @label With Include Blank
  # @note
  #   Include blank adds an empty option that can be selected.
  #   Useful when selection is optional.
  def with_include_blank
    render(Form::Field::SelectComponent.new(
      name: "category",
      label: "Category",
      options: %w[Technology Sports Music Art],
      include_blank: true
    ))
  end

  # @label With Custom Blank Text
  # @note
  #   Provide a string to include_blank for custom blank option text.
  def with_custom_blank_text
    render(Form::Field::SelectComponent.new(
      name: "category",
      label: "Category",
      options: %w[Technology Sports Music Art],
      include_blank: "-- No category --"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the select.
  #   They are associated with the select via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::SelectComponent.new(
      name: "timezone",
      label: "Timezone",
      options: [
        [ "Eastern Time (US & Canada)", "eastern" ],
        [ "Central Time (US & Canada)", "central" ],
        [ "Pacific Time (US & Canada)", "pacific" ]
      ],
      hint: "Select your preferred timezone for notifications."
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::SelectComponent.new(
      name: "priority",
      label: "Priority",
      options: %w[Low Medium High Critical],
      required: true,
      prompt: "Select priority..."
    ))
  end

  # @label With Selected Value
  # @note
  #   Pre-select an option by providing the value parameter.
  def with_selected_value
    render(Form::Field::SelectComponent.new(
      name: "status",
      label: "Status",
      options: %w[Draft Published Archived],
      value: "Published"
    ))
  end

  # @label Label-Value Pairs
  # @note
  #   Use arrays of [label, value] pairs for different display text and values.
  #   This is useful when the display name differs from the stored value.
  def label_value_pairs
    render(Form::Field::SelectComponent.new(
      name: "country",
      label: "Country",
      options: [
        [ "United States", "us" ],
        [ "Canada", "ca" ],
        [ "Mexico", "mx" ],
        [ "United Kingdom", "uk" ],
        [ "Australia", "au" ]
      ],
      value: "uk"
    ))
  end

  # @label Grouped Options
  # @note
  #   Use a hash to group options under optgroup labels.
  #   Great for organizing many options into logical categories.
  def grouped_options
    render(Form::Field::SelectComponent.new(
      name: "city",
      label: "City",
      options: {
        "North America" => [
          [ "New York", "ny" ],
          [ "Los Angeles", "la" ],
          [ "Toronto", "to" ],
          [ "Vancouver", "va" ]
        ],
        "Europe" => [
          [ "London", "lo" ],
          [ "Paris", "pa" ],
          [ "Berlin", "be" ],
          [ "Amsterdam", "am" ]
        ],
        "Asia" => [
          [ "Tokyo", "tk" ],
          [ "Singapore", "sg" ],
          [ "Hong Kong", "hk" ]
        ]
      },
      prompt: "Select a city..."
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The select is marked as invalid for screen readers.
  def with_error
    render(Form::Field::SelectComponent.new(
      name: "category",
      label: "Category",
      options: %w[Technology Sports Music Art],
      prompt: "Select a category...",
      error: "must be selected"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::SelectComponent.new(
      name: "role",
      label: "Role",
      options: %w[Admin Editor Viewer],
      error: [ "must be selected", "cannot be changed while active" ]
    ))
  end

  # @label Small Size
  # @note
  #   Small size is suitable for compact UIs or inline forms.
  def small_size
    render(Form::Field::SelectComponent.new(
      name: "items_per_page",
      label: "Items per page",
      options: %w[10 25 50 100],
      size: :small,
      value: "25"
    ))
  end

  # @label Medium Size
  # @note
  #   Medium size is the default and works well in most contexts.
  def medium_size
    render(Form::Field::SelectComponent.new(
      name: "sort_by",
      label: "Sort by",
      options: [
        [ "Name (A-Z)", "name_asc" ],
        [ "Name (Z-A)", "name_desc" ],
        [ "Date (Newest)", "date_desc" ],
        [ "Date (Oldest)", "date_asc" ]
      ],
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size is suitable for prominent selections or touch interfaces.
  def large_size
    render(Form::Field::SelectComponent.new(
      name: "plan",
      label: "Select Plan",
      options: [
        [ "Free - $0/month", "free" ],
        [ "Basic - $9/month", "basic" ],
        [ "Pro - $29/month", "pro" ],
        [ "Enterprise - Contact us", "enterprise" ]
      ],
      size: :large,
      prompt: "Choose a plan..."
    ))
  end

  # @label All Sizes
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label Disabled
  # @note
  #   Disabled selects cannot be interacted with.
  def disabled
    render(Form::Field::SelectComponent.new(
      name: "locked_status",
      label: "Status (Locked)",
      options: %w[Active Inactive],
      value: "Active",
      disabled: true
    ))
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::SelectComponent.new(
      name: "filter",
      label: "Filter",
      options: %w[All Active Completed],
      data: {
        controller: "filter",
        action: "change->filter#apply",
        filter_url_value: "/api/items"
      }
    ))
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, grouped options, prompt, hint, and required.
  def complete_example
    render(Form::Field::SelectComponent.new(
      name: "department",
      label: "Department",
      options: {
        "Engineering" => [
          [ "Frontend Development", "frontend" ],
          [ "Backend Development", "backend" ],
          [ "DevOps", "devops" ],
          [ "QA Engineering", "qa" ]
        ],
        "Design" => [
          [ "UI Design", "ui" ],
          [ "UX Research", "ux" ],
          [ "Brand Design", "brand" ]
        ],
        "Product" => [
          [ "Product Management", "pm" ],
          [ "Product Analytics", "analytics" ]
        ]
      },
      prompt: "Select your department...",
      hint: "This will determine your team assignment.",
      required: true
    ))
  end
end
