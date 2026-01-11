# frozen_string_literal: true

# Form::Field::PasswordInputComponent
#
# A password input component with show/hide toggle functionality.
# Extends the base field component with password-specific features.
#
# @example Basic usage
#   <%= render Form::Field::PasswordInputComponent.new(name: "password") %>
#
# @example With label
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password"
#   ) %>
#
# @example With hint
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     hint: "Must be at least 8 characters"
#   ) %>
#
# @example With error state
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     error: "is too short"
#   ) %>
#
# @example Required field
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     required: true
#   ) %>
#
# @example Without show/hide toggle
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     show_toggle: false
#   ) %>
#
# @example New password with autocomplete (RECOMMENDED for signup/password reset)
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "New Password",
#     autocomplete: "new-password",
#     hint: "Use at least 8 characters with a mix of letters, numbers, and symbols"
#   ) %>
#
# @example Current password with autocomplete (RECOMMENDED for login)
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     autocomplete: "current-password"
#   ) %>
#
# @example Password confirmation with autocomplete
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password_confirmation",
#     label: "Confirm Password",
#     autocomplete: "new-password"
#   ) %>
#
# @example Sensitive context without toggle (public terminal, shared screen)
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     autocomplete: "current-password",
#     show_toggle: false
#   ) %>
#
# @example With pattern validation
#   <%= render Form::Field::PasswordInputComponent.new(
#     name: "password",
#     label: "Password",
#     pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$",
#     title: "Password must contain at least one uppercase letter, one lowercase letter, one number, and be at least 8 characters long"
#   ) %>
#
class Form::Field::PasswordInputComponent < Form::Field::BaseComponent
  # @param name [String] The input name attribute (required)
  # @param id [String] The input id attribute (defaults to name)
  # @param value [String] The input value
  # @param label [String] The label text
  # @param placeholder [String] The placeholder text
  # @param hint [String] Help text displayed below the input
  # @param error [String, Array<String>] Error message(s)
  # @param required [Boolean] Whether the field is required
  # @param disabled [Boolean] Whether the field is disabled
  # @param readonly [Boolean] Whether the field is readonly
  # @param size [Symbol] The input size (:small, :medium, :large)
  # @param show_toggle [Boolean] Whether to show the show/hide toggle button (set false in sensitive contexts)
  # @param autocomplete [String] Autocomplete attribute - use "new-password" for signup/reset, "current-password" for login
  # @param pattern [String] HTML5 pattern attribute for client-side validation
  # @param title [String] Title attribute shown on pattern validation failure
  # @param html_attributes [Hash] Additional HTML attributes for the input
  def initialize(
    name:,
    show_toggle: true,
    **options
  )
    super(name: name, **options)
    @show_toggle = show_toggle
  end

  # Whether to show the password visibility toggle
  def show_toggle?
    @show_toggle && !@disabled && !@readonly
  end

  private

  def input_wrapper_classes
    "relative"
  end

  def input_classes
    classes = [
      base_field_classes,
      size_field_classes,
      state_field_classes
    ]
    classes << "pr-10" if show_toggle?
    classes << @html_attributes[:class] if @html_attributes[:class]
    classes.compact.join(" ")
  end

  def toggle_button_classes
    "absolute inset-y-0 right-0 flex items-center pr-3 " \
    "hover:text-gray-600 focus:outline-none focus:text-gray-600 transition-colors"
  end

  def toggle_icon_classes
    has_error? ? "text-red-400" : "text-gray-400"
  end

  def input_attributes
    attrs = base_field_attributes.merge(
      type: "password",
      value: @value
    )

    if show_toggle?
      attrs[:"data-components--password-input-target"] = "input"
    end

    merge_html_attributes(attrs)
  end

  def merged_input_attributes
    input_attributes.merge(class: input_classes)
  end
end
