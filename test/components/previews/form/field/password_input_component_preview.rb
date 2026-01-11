# frozen_string_literal: true

# @label Form::Field::PasswordInput
# @logical_path Form/Field
# @note
#   A password input component with show/hide toggle functionality.
#   Provides consistent styling, labels, hints, error handling, and
#   accessibility features. Includes Stimulus controller for toggling visibility.
class Form::Field::PasswordInputComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   Includes the show/hide toggle button by default.
  def default
    render(Form::Field::PasswordInputComponent.new(name: "password"))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the password field.
  #   The label is automatically associated with the input for accessibility.
  def with_label
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password"
    ))
  end

  # @label With Placeholder
  # @note
  #   Placeholders provide hints about the expected input format.
  def with_placeholder
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      placeholder: "Enter your password"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the input.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      hint: "Must be at least 8 characters with one uppercase letter and one number."
    ))
  end

  # @label With Error
  # @note
  #   Error state with red border and error message.
  #   The error message is announced to screen readers via role="alert".
  def with_error
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      value: "weak",
      error: "is too short (minimum is 8 characters)"
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show an asterisk (*) next to the label
  #   and have the required attribute for browser validation.
  def required_field
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      placeholder: "Enter your password",
      required: true
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled inputs cannot be edited and have reduced opacity.
  #   The toggle button is hidden when disabled.
  def disabled_state
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      value: "cannot-edit",
      disabled: true
    ))
  end

  # @label Readonly State
  # @note
  #   Readonly inputs can be focused and selected but not edited.
  #   The toggle button is hidden when readonly.
  def readonly_state
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      value: "readonly-value",
      readonly: true
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary forms.
  def small_size
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      size: :small,
      placeholder: "Enter password"
    ))
  end

  # @label Medium Size (Default)
  # @note
  #   Standard size for most use cases.
  def medium_size
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      size: :medium,
      placeholder: "Enter password"
    ))
  end

  # @label Large Size
  # @note
  #   Larger size for emphasis or better touch targets on mobile.
  def large_size
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      size: :large,
      placeholder: "Enter password"
    ))
  end

  # @label Without Toggle
  # @note
  #   Disable the show/hide toggle button by setting show_toggle: false.
  #   Useful for sensitive contexts where password visibility should not be toggled.
  def without_toggle
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      placeholder: "Enter password",
      show_toggle: false
    ))
  end

  # @label New Password
  # @note
  #   Configuration for new password creation with autocomplete hint.
  def new_password
    render(Form::Field::PasswordInputComponent.new(
      name: "new_password",
      label: "New Password",
      placeholder: "Create a password",
      hint: "Use at least 8 characters with a mix of letters, numbers, and symbols.",
      autocomplete: "new-password",
      required: true
    ))
  end

  # @label Current Password
  # @note
  #   Configuration for current password confirmation.
  def current_password
    render(Form::Field::PasswordInputComponent.new(
      name: "current_password",
      label: "Current Password",
      placeholder: "Enter your current password",
      autocomplete: "current-password",
      required: true
    ))
  end

  # @label With Pattern Validation
  # @note
  #   Uses HTML5 pattern attribute for client-side validation.
  #   The title attribute provides feedback about the requirements.
  def with_pattern
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$",
      title: "Password must contain at least one uppercase letter, one lowercase letter, one number, and be at least 8 characters long",
      hint: "Must include uppercase, lowercase, and number"
    ))
  end

  # @label With Length Constraints
  # @note
  #   Uses minlength and maxlength attributes for validation.
  def with_length_constraints
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      minlength: 8,
      maxlength: 72,
      hint: "Between 8 and 72 characters"
    ))
  end

  # @label All Sizes Comparison
  # @note
  #   Visual comparison of all three size variants.
  def all_sizes
    render_with_template
  end

  # @label Complete Example
  # @note
  #   A fully-featured password input with label, hint, placeholder, and required state.
  def complete
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Create Password",
      placeholder: "Enter a secure password",
      hint: "Your password must be at least 8 characters and include uppercase, lowercase, and numbers.",
      required: true,
      minlength: 8,
      autocomplete: "new-password"
    ))
  end

  # @label Error State with Toggle
  # @note
  #   Shows how the toggle button icon color updates to match error state.
  def error_with_toggle
    render(Form::Field::PasswordInputComponent.new(
      name: "password",
      label: "Password",
      value: "weak",
      error: "is too weak - add uppercase letters and numbers"
    ))
  end

  # @label Nested Name
  # @note
  #   Supports Rails-style nested attribute names with automatic ID generation.
  def nested_name
    render(Form::Field::PasswordInputComponent.new(
      name: "user[password]",
      label: "Password",
      placeholder: "Enter your password"
    ))
  end
end
