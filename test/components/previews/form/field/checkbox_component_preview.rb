# frozen_string_literal: true

# @label Form::Field::Checkbox
# @logical_path Form/Field
# @note
#   A flexible checkbox component that provides consistent styling,
#   labels, hints, error handling, and accessibility features.
#   Supports checked/unchecked states, custom values, and label positioning.
class Form::Field::CheckboxComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   Includes a hidden field for unchecked value by default.
  def default
    render(Form::Field::CheckboxComponent.new(name: "agree"))
  end

  # @label With Label
  # @note
  #   Add a label to describe the checkbox option.
  #   The label is clickable and associated with the checkbox for accessibility.
  def with_label
    render(Form::Field::CheckboxComponent.new(
      name: "terms",
      label: "I agree to the terms and conditions"
    ))
  end

  # @label Checked by Default
  # @note
  #   Set checked: true to render the checkbox as checked.
  def checked
    render(Form::Field::CheckboxComponent.new(
      name: "newsletter",
      label: "Subscribe to our newsletter",
      checked: true
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context below the checkbox.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::CheckboxComponent.new(
      name: "marketing",
      label: "Receive marketing emails",
      hint: "You can unsubscribe at any time from your account settings."
    ))
  end

  # @label Required Field
  # @note
  #   Required checkboxes show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::CheckboxComponent.new(
      name: "terms",
      label: "I accept the terms of service",
      required: true
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The checkbox is marked as invalid for screen readers.
  def with_error
    render(Form::Field::CheckboxComponent.new(
      name: "terms",
      label: "I agree to the terms and conditions",
      error: "must be accepted to continue"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::CheckboxComponent.new(
      name: "consent",
      label: "I consent to data processing",
      error: [ "is required", "must be acknowledged" ]
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled checkboxes cannot be interacted with and have reduced opacity.
  def disabled
    render(Form::Field::CheckboxComponent.new(
      name: "locked_option",
      label: "This option is locked",
      disabled: true
    ))
  end

  # @label Disabled and Checked
  # @note
  #   A disabled checkbox that is also checked, useful for displaying
  #   locked selections.
  def disabled_checked
    render(Form::Field::CheckboxComponent.new(
      name: "premium_feature",
      label: "Premium feature enabled",
      checked: true,
      disabled: true
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary options.
  def small_size
    render(Form::Field::CheckboxComponent.new(
      name: "compact_option",
      label: "Enable compact mode",
      size: :small
    ))
  end

  # @label Medium Size
  # @note
  #   Default size suitable for most form layouts.
  def medium_size
    render(Form::Field::CheckboxComponent.new(
      name: "standard_option",
      label: "Standard checkbox size",
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size for prominent options or touch-friendly interfaces.
  def large_size
    render(Form::Field::CheckboxComponent.new(
      name: "prominent_option",
      label: "I want to receive important updates",
      size: :large
    ))
  end

  # @label All Sizes
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label Custom Value
  # @note
  #   Set a custom value that will be submitted when the checkbox is checked.
  #   Default value is "1".
  def custom_value
    render(Form::Field::CheckboxComponent.new(
      name: "notification_preference",
      label: "Enable email notifications",
      value: "email_enabled"
    ))
  end

  # @label Without Hidden Field
  # @note
  #   By default, a hidden field with value "0" is included for unchecked state.
  #   Set include_hidden: false to disable this behavior.
  def without_hidden_field
    render(Form::Field::CheckboxComponent.new(
      name: "optional_feature",
      label: "Enable optional feature",
      include_hidden: false
    ))
  end

  # @label With Custom Label Content
  # @note
  #   Use the label_content slot for labels with links or other HTML content.
  def with_label_slot
    render(Form::Field::CheckboxComponent.new(name: "terms")) do |checkbox|
      checkbox.with_label_content do
        "I agree to the <a href='/terms' class='text-blue-600 hover:text-blue-800 underline'>terms of service</a> and <a href='/privacy' class='text-blue-600 hover:text-blue-800 underline'>privacy policy</a>".html_safe
      end
    end
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::CheckboxComponent.new(
      name: "auto_save",
      label: "Enable auto-save",
      data: {
        controller: "toggle",
        action: "change->toggle#update"
      }
    ))
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, hint, and required indicator.
  def complete_example
    render(Form::Field::CheckboxComponent.new(
      name: "data_consent",
      label: "I consent to the processing of my personal data",
      hint: "Your data will be processed in accordance with our privacy policy and GDPR regulations.",
      required: true
    ))
  end

  # @label Form Context
  # @note
  #   Example showing multiple checkboxes as might appear in a real form.
  def form_context
    render_with_template
  end
end
