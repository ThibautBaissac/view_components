# frozen_string_literal: true

# @label Form::Field::TextInput
# @logical_path Form/Field
# @note
#   A flexible text input component that provides consistent styling,
#   labels, hints, error handling, and accessibility features.
#   Supports different input types, sizes, and icon slots.
class Form::Field::TextInputComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name attribute.
  #   The input will have default text type and medium size.
  def default
    render(Form::Field::TextInputComponent.new(name: "username"))
  end

  # @label With Label
  # @note
  #   Add a label to provide context for the input field.
  #   The label is automatically associated with the input for accessibility.
  def with_label
    render(Form::Field::TextInputComponent.new(
      name: "email",
      label: "Email Address"
    ))
  end

  # @label With Placeholder
  # @note
  #   Placeholders provide hints about the expected input format.
  def with_placeholder
    render(Form::Field::TextInputComponent.new(
      name: "email",
      label: "Email Address",
      placeholder: "you@example.com"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context or instructions below the input.
  #   They are associated with the input via aria-describedby for accessibility.
  def with_hint
    render(Form::Field::TextInputComponent.new(
      name: "email",
      label: "Email Address",
      placeholder: "you@example.com",
      hint: "We'll never share your email with anyone else."
    ))
  end

  # @label Required Field
  # @note
  #   Required fields show a visual indicator and have the required HTML attribute.
  def required
    render(Form::Field::TextInputComponent.new(
      name: "username",
      label: "Username",
      required: true,
      placeholder: "Enter your username"
    ))
  end

  # @label With Error
  # @note
  #   Error state applies red styling and displays an error message.
  #   The input is marked as invalid for screen readers.
  def with_error
    render(Form::Field::TextInputComponent.new(
      name: "email",
      label: "Email Address",
      value: "invalid-email",
      error: "is not a valid email address"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::TextInputComponent.new(
      name: "password",
      label: "Password",
      error: [ "is too short", "must include a number", "must include a special character" ]
    ))
  end

  # @label Email Type
  # @note
  #   Email type provides native browser validation and mobile keyboard optimization.
  def email_type
    render(Form::Field::TextInputComponent.new(
      name: "email",
      label: "Email",
      type: :email,
      placeholder: "you@example.com",
      autocomplete: "email"
    ))
  end

  # @label Telephone Type
  # @note
  #   Tel type shows a numeric keyboard on mobile devices.
  def tel_type
    render(Form::Field::TextInputComponent.new(
      name: "phone",
      label: "Phone Number",
      type: :tel,
      placeholder: "(555) 123-4567",
      autocomplete: "tel"
    ))
  end

  # @label URL Type
  # @note
  #   URL type validates web addresses and shows appropriate keyboard on mobile.
  def url_type
    render(Form::Field::TextInputComponent.new(
      name: "website",
      label: "Website",
      type: :url,
      placeholder: "https://example.com"
    ))
  end

  # @label Search Type
  # @note
  #   Search type may show a search icon and clear button in some browsers.
  def search_type
    render(Form::Field::TextInputComponent.new(
      name: "query",
      label: "Search",
      type: :search,
      placeholder: "Search..."
    ))
  end

  # @label Number Type
  # @note
  #   Number type provides numeric input with optional min, max, and step attributes.
  def number_type
    render(Form::Field::TextInputComponent.new(
      name: "quantity",
      label: "Quantity",
      type: :number,
      value: "1",
      min: 1,
      max: 100,
      step: 1
    ))
  end

  # @label Small Size
  # @note
  #   Small size is suitable for compact layouts or inline forms.
  def small_size
    render(Form::Field::TextInputComponent.new(
      name: "code",
      label: "Verification Code",
      size: :small,
      placeholder: "Enter code",
      maxlength: 6
    ))
  end

  # @label Medium Size (Default)
  # @note
  #   Medium is the default size, suitable for most use cases.
  def medium_size
    render(Form::Field::TextInputComponent.new(
      name: "name",
      label: "Full Name",
      size: :medium,
      placeholder: "Enter your full name"
    ))
  end

  # @label Large Size
  # @note
  #   Large size is suitable for prominent input fields or touch interfaces.
  def large_size
    render(Form::Field::TextInputComponent.new(
      name: "title",
      label: "Title",
      size: :large,
      placeholder: "Enter a title"
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
  #   Disabled inputs cannot be focused or edited.
  def disabled
    render(Form::Field::TextInputComponent.new(
      name: "readonly_field",
      label: "Disabled Field",
      value: "Cannot edit this",
      disabled: true
    ))
  end

  # @label Readonly
  # @note
  #   Readonly inputs can be focused and selected but not edited.
  def readonly
    render(Form::Field::TextInputComponent.new(
      name: "api_key",
      label: "API Key",
      value: "sk-1234567890abcdef",
      readonly: true
    ))
  end

  # @label With Leading Icon
  # @note
  #   Leading icons help identify the type of expected input.
  def with_leading_icon
    render_with_template
  end

  # @label With Trailing Icon
  # @note
  #   Trailing icons can indicate validation state or provide actions.
  def with_trailing_icon
    render_with_template
  end

  # @label With Both Icons
  # @note
  #   Combine leading and trailing icons for rich input experiences.
  def with_both_icons
    render_with_template
  end

  # @label Complete Example
  # @note
  #   A fully-featured input with label, hint, placeholder, icon, and required state.
  def complete
    render_with_template
  end

  # @label Error with Icon
  # @note
  #   Icons update their color to match the error state.
  def error_with_icon
    render_with_template
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::TextInputComponent.new(
      name: "search",
      label: "Live Search",
      type: :search,
      placeholder: "Type to search...",
      data: {
        controller: "search",
        action: "input->search#search",
        search_url_value: "/api/search"
      }
    ))
  end

  # @label Nested Name
  # @note
  #   Supports Rails-style nested attribute names with automatic ID generation.
  def nested_name
    render(Form::Field::TextInputComponent.new(
      name: "user[profile][first_name]",
      label: "First Name",
      placeholder: "Enter your first name"
    ))
  end
end
