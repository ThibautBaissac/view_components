# frozen_string_literal: true

# @label Form::Field::CheckboxGroup
# @logical_path Form/Field
# @note
#   A checkbox group component that renders multiple related checkboxes with
#   consistent styling, labels, hints, error handling, and accessibility features.
#   Uses composition with CheckboxComponent to avoid code duplication.
class Form::Field::CheckboxGroupComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with just a name and options array.
  def default
    render(Form::Field::CheckboxGroupComponent.new(
      name: "interests[]",
      options: [ "Reading", "Sports", "Music", "Travel" ]
    ))
  end

  # @label With Group Label
  # @note
  #   Add a legend to describe the group of checkboxes.
  def with_label
    render(Form::Field::CheckboxGroupComponent.new(
      name: "interests[]",
      label: "What are your interests?",
      options: [ "Reading", "Sports", "Music", "Travel", "Cooking" ]
    ))
  end

  # @label With Pre-selected Values
  # @note
  #   Pass an array of values to pre-select checkboxes.
  def with_selected_values
    render(Form::Field::CheckboxGroupComponent.new(
      name: "notifications[]",
      label: "Notification Preferences",
      options: [
        [ "Email notifications", "email" ],
        [ "SMS notifications", "sms" ],
        [ "Push notifications", "push" ],
        [ "Weekly digest", "digest" ]
      ],
      value: [ "email", "push" ]
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context below the checkbox group.
  def with_hint
    render(Form::Field::CheckboxGroupComponent.new(
      name: "terms[]",
      label: "Legal Agreements",
      options: [
        [ "Terms of Service", "tos" ],
        [ "Privacy Policy", "privacy" ],
        [ "Cookie Policy", "cookies" ]
      ],
      hint: "You must accept all agreements to continue."
    ))
  end

  # @label Required Field
  # @note
  #   Required groups show a visual indicator in the legend.
  def required
    render(Form::Field::CheckboxGroupComponent.new(
      name: "agreements[]",
      label: "Required Agreements",
      options: [
        [ "I accept the Terms of Service", "tos" ],
        [ "I accept the Privacy Policy", "privacy" ]
      ],
      required: true
    ))
  end

  # @label With Error
  # @note
  #   Error state applies styling and displays an error message for the group.
  def with_error
    render(Form::Field::CheckboxGroupComponent.new(
      name: "categories[]",
      label: "Categories",
      options: [ "Technology", "Sports", "Entertainment", "Business" ],
      error: "must select at least one category"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::CheckboxGroupComponent.new(
      name: "skills[]",
      label: "Required Skills",
      options: [ "Ruby", "Rails", "JavaScript", "SQL" ],
      error: [ "is required", "must select at least 2 skills" ]
    ))
  end

  # @label Inline Layout
  # @note
  #   Inline layout displays checkboxes horizontally, useful for short lists.
  def inline_layout
    render(Form::Field::CheckboxGroupComponent.new(
      name: "days[]",
      label: "Available Days",
      options: [ "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" ],
      layout: :inline
    ))
  end

  # @label Stacked Layout (Default)
  # @note
  #   Stacked layout displays checkboxes vertically, suitable for longer labels.
  def stacked_layout
    render(Form::Field::CheckboxGroupComponent.new(
      name: "features[]",
      label: "Enabled Features",
      options: [
        [ "API Access with unlimited requests", "api" ],
        [ "Advanced Dashboard with real-time analytics", "dashboard" ],
        [ "Custom Reports and data exports", "reports" ],
        [ "Priority Support with 24/7 availability", "support" ]
      ],
      layout: :stacked
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary options.
  def small_size
    render(Form::Field::CheckboxGroupComponent.new(
      name: "tags[]",
      label: "Tags",
      options: [ "Frontend", "Backend", "DevOps", "Design" ],
      size: :small,
      layout: :inline
    ))
  end

  # @label Medium Size (Default)
  # @note
  #   Default size suitable for most form layouts.
  def medium_size
    render(Form::Field::CheckboxGroupComponent.new(
      name: "categories[]",
      label: "Categories",
      options: [ "Technology", "Business", "Science", "Arts" ],
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size for prominent options or touch-friendly interfaces.
  def large_size
    render(Form::Field::CheckboxGroupComponent.new(
      name: "priorities[]",
      label: "Top Priorities",
      options: [
        [ "Customer satisfaction", "customer" ],
        [ "Product quality", "quality" ],
        [ "Fast delivery", "speed" ]
      ],
      size: :large
    ))
  end

  # @label All Sizes Comparison
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label Disabled State
  # @note
  #   Disabled groups cannot be interacted with.
  def disabled
    render(Form::Field::CheckboxGroupComponent.new(
      name: "locked[]",
      label: "Locked Options",
      options: [ "Option 1", "Option 2", "Option 3" ],
      value: [ "Option 1" ],
      disabled: true
    ))
  end

  # @label With Label-Value Pairs
  # @note
  #   Use label-value pairs when display text differs from the submitted value.
  def label_value_pairs
    render(Form::Field::CheckboxGroupComponent.new(
      name: "permissions[]",
      label: "User Permissions",
      options: [
        [ "Read Access", "read" ],
        [ "Write Access", "write" ],
        [ "Delete Access", "delete" ],
        [ "Admin Access", "admin" ]
      ],
      value: [ "read", "write" ]
    ))
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, hint, required, and pre-selected values.
  def complete_example
    render(Form::Field::CheckboxGroupComponent.new(
      name: "marketing[]",
      label: "Marketing Preferences",
      options: [
        [ "Product updates and announcements", "product_updates" ],
        [ "Special offers and discounts", "offers" ],
        [ "Industry news and insights", "news" ],
        [ "Event invitations", "events" ]
      ],
      value: [ "product_updates" ],
      hint: "We respect your privacy. You can change these preferences at any time.",
      required: true
    ))
  end

  # @label Form Context
  # @note
  #   Example showing checkbox groups in a complete form context.
  def form_context
    render_with_template
  end
end
