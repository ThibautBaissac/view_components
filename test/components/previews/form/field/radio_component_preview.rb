# frozen_string_literal: true

# @label Form::Field::Radio
# @logical_path Form/Field
# @note
#   A flexible radio button component that provides consistent styling,
#   labels, hints, error handling, and accessibility features.
#   Radio buttons are typically used in groups where only one option can be selected.
class Form::Field::RadioComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with name and value attributes.
  def default
    render(Form::Field::RadioComponent.new(name: "plan", value: "basic"))
  end

  # @label With Label
  # @note
  #   Add a label to describe the radio option.
  #   The label is clickable and associated with the radio for accessibility.
  def with_label
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "pro",
      label: "Pro Plan - $19/month"
    ))
  end

  # @label Checked by Default
  # @note
  #   Set checked: true to render the radio as selected.
  def checked
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "basic",
      label: "Basic Plan - Free",
      checked: true
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context below the radio button.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "enterprise",
      label: "Enterprise Plan",
      hint: "Contact us for custom pricing and dedicated support."
    ))
  end

  # @label Required Field
  # @note
  #   Required radios show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "pro",
      label: "Pro Plan",
      required: true
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The radio is marked as invalid for screen readers.
  def with_error
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "basic",
      label: "Basic Plan",
      error: "Please select a plan to continue"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "basic",
      label: "Basic Plan",
      error: [ "is required", "must be selected" ]
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled radios cannot be interacted with and have reduced opacity.
  def disabled
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "legacy",
      label: "Legacy Plan (no longer available)",
      disabled: true
    ))
  end

  # @label Disabled and Checked
  # @note
  #   A disabled radio that is also checked, useful for displaying
  #   locked selections.
  def disabled_checked
    render(Form::Field::RadioComponent.new(
      name: "plan",
      value: "grandfathered",
      label: "Grandfathered Plan",
      checked: true,
      disabled: true
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary options.
  def small_size
    render(Form::Field::RadioComponent.new(
      name: "priority",
      value: "low",
      label: "Low priority",
      size: :small
    ))
  end

  # @label Medium Size
  # @note
  #   Default size suitable for most form layouts.
  def medium_size
    render(Form::Field::RadioComponent.new(
      name: "priority",
      value: "medium",
      label: "Medium priority",
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size for prominent options or touch-friendly interfaces.
  def large_size
    render(Form::Field::RadioComponent.new(
      name: "priority",
      value: "high",
      label: "High priority",
      size: :large
    ))
  end

  # @label All Sizes
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label With Custom Label Content
  # @note
  #   Use the label_content slot for labels with formatted text or HTML content.
  def with_label_slot
    render(Form::Field::RadioComponent.new(name: "plan", value: "pro")) do |radio|
      radio.with_label_content do
        "Pro Plan - <span class='text-green-600 font-semibold'>$19/month</span> <span class='text-gray-500 text-sm'>(Most popular)</span>".html_safe
      end
    end
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::RadioComponent.new(
      name: "theme",
      value: "dark",
      label: "Dark theme",
      data: {
        controller: "theme-switcher",
        action: "change->theme-switcher#switch"
      }
    ))
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, hint, and required indicator.
  def complete_example
    render(Form::Field::RadioComponent.new(
      name: "billing_cycle",
      value: "annual",
      label: "Annual Billing",
      hint: "Save 20% with annual billing. You'll be charged $228/year instead of $285.",
      required: true
    ))
  end

  # @label Radio Group Example
  # @note
  #   Example showing multiple radios in a group context.
  #   All radios share the same name, creating mutual exclusivity.
  def radio_group
    render_with_template
  end

  # @label Form Context
  # @note
  #   Example showing radios as they might appear in a real form.
  def form_context
    render_with_template
  end
end
