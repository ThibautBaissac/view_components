# frozen_string_literal: true

# @label Form::Field::Switch
# @logical_path Form/Field
# @note
#   A toggle switch component that provides a visual alternative to checkboxes
#   for binary on/off settings. Provides consistent styling, labels, hints,
#   error handling, and accessibility features using role="switch" for proper semantics.
class Form::Field::SwitchComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   Includes a hidden field for off value by default.
  def default
    render(Form::Field::SwitchComponent.new(name: "notifications"))
  end

  # @label With Label
  # @note
  #   Add a label to describe the switch option.
  #   The label is clickable and associated with the switch for accessibility.
  def with_label
    render(Form::Field::SwitchComponent.new(
      name: "dark_mode",
      label: "Enable dark mode"
    ))
  end

  # @label Checked by Default
  # @note
  #   Set checked: true to render the switch in the on position.
  def checked
    render(Form::Field::SwitchComponent.new(
      name: "notifications",
      label: "Push notifications",
      checked: true
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context below the switch.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::SwitchComponent.new(
      name: "auto_save",
      label: "Auto-save documents",
      hint: "Documents will be saved automatically every 30 seconds."
    ))
  end

  # @label Required Field
  # @note
  #   Required switches show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::SwitchComponent.new(
      name: "terms",
      label: "I accept the terms of service",
      required: true
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The switch is marked as invalid for screen readers.
  def with_error
    render(Form::Field::SwitchComponent.new(
      name: "terms",
      label: "Accept terms and conditions",
      error: "must be accepted to continue"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::SwitchComponent.new(
      name: "consent",
      label: "I consent to data processing",
      error: [ "is required", "must be acknowledged" ]
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled switches cannot be interacted with and have reduced opacity.
  def disabled
    render(Form::Field::SwitchComponent.new(
      name: "locked_feature",
      label: "Premium feature",
      disabled: true
    ))
  end

  # @label Disabled and Checked
  # @note
  #   A disabled switch that is also on, useful for displaying
  #   locked settings.
  def disabled_checked
    render(Form::Field::SwitchComponent.new(
      name: "premium_feature",
      label: "Premium feature enabled",
      checked: true,
      disabled: true
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary settings.
  def small_size
    render(Form::Field::SwitchComponent.new(
      name: "compact_option",
      label: "Enable compact mode",
      size: :small
    ))
  end

  # @label Medium Size
  # @note
  #   Default size suitable for most form layouts.
  def medium_size
    render(Form::Field::SwitchComponent.new(
      name: "default_option",
      label: "Standard notifications",
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size for prominent settings or touch-friendly interfaces.
  def large_size
    render(Form::Field::SwitchComponent.new(
      name: "prominent_option",
      label: "Enable important feature",
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
  #   Set a custom value that will be submitted when the switch is on.
  #   Default value is "1".
  def custom_value
    render(Form::Field::SwitchComponent.new(
      name: "notification_preference",
      label: "Enable email notifications",
      value: "email_enabled"
    ))
  end

  # @label Without Hidden Field
  # @note
  #   By default, a hidden field with value "0" is included for off state.
  #   Set include_hidden: false to disable this behavior.
  def without_hidden_field
    render(Form::Field::SwitchComponent.new(
      name: "optional_switch",
      label: "Optional setting",
      include_hidden: false
    ))
  end

  # @label With Custom Label Content
  # @note
  #   Use the label_content slot for labels with links or other HTML content.
  def with_label_slot
    render(Form::Field::SwitchComponent.new(name: "terms")) do |switch|
      switch.with_label_content do
        "I agree to the <a href='/terms' class='text-blue-600 hover:underline'>terms and conditions</a>".html_safe
      end
    end
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::SwitchComponent.new(
      name: "live_preview",
      label: "Enable live preview",
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
    render(Form::Field::SwitchComponent.new(
      name: "data_consent",
      label: "I consent to the processing of my personal data",
      hint: "Your data will be processed in accordance with our privacy policy and GDPR regulations.",
      required: true
    ))
  end

  # @label Form Context
  # @note
  #   Example showing multiple switches as might appear in a settings form.
  def form_context
    render_with_template
  end
end
