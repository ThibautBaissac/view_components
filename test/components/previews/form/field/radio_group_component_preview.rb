# frozen_string_literal: true

# @label Form::Field::RadioGroup
# @logical_path Form/Field
# @note
#   A radio group component that wraps multiple radio buttons in a fieldset
#   with proper accessibility. Radio groups ensure only one option can be selected.
#   Use this for mutually exclusive choices like plans, settings, or preferences.
class Form::Field::RadioGroupComponentPreview < ViewComponent::Preview
  # @label Default
  # @note
  #   The simplest usage with name and options array.
  def default
    render(Form::Field::RadioGroupComponent.new(
      name: "plan",
      options: [ "Basic", "Pro", "Enterprise" ]
    ))
  end

  # @label With Label
  # @note
  #   Add a legend to describe the group of options.
  #   The legend is associated with the fieldset for screen readers.
  def with_label
    render(Form::Field::RadioGroupComponent.new(
      name: "plan",
      label: "Choose your subscription plan",
      options: [ "Free", "Pro - $19/month", "Enterprise - $99/month" ]
    ))
  end

  # @label With Label-Value Pairs
  # @note
  #   Use label-value pairs when the displayed text differs from the submitted value.
  def with_label_value_pairs
    render(Form::Field::RadioGroupComponent.new(
      name: "billing_cycle",
      label: "Billing Cycle",
      options: [
        [ "Monthly - $29/month", "monthly" ],
        [ "Annual - $278/year (Save 20%)", "annual" ],
        [ "Lifetime - $499 one-time", "lifetime" ]
      ]
    ))
  end

  # @label Pre-selected Value
  # @note
  #   Set value to pre-select a radio button.
  def with_selected_value
    render(Form::Field::RadioGroupComponent.new(
      name: "theme",
      label: "Theme Preference",
      options: [
        [ "Light Mode", "light" ],
        [ "Dark Mode", "dark" ],
        [ "Auto (System)", "auto" ]
      ],
      value: "dark"
    ))
  end

  # @label With Hint
  # @note
  #   Hints provide additional context for the entire group.
  #   They are associated with the fieldset via aria-describedby.
  def with_hint
    render(Form::Field::RadioGroupComponent.new(
      name: "payment_method",
      label: "Payment Method",
      options: [
        [ "Credit Card", "card" ],
        [ "PayPal", "paypal" ],
        [ "Bank Transfer", "bank" ]
      ],
      hint: "You can change your payment method later in account settings."
    ))
  end

  # @label Required Field
  # @note
  #   Required groups show a visual indicator in the legend.
  #   All radio buttons have the required attribute.
  def required
    render(Form::Field::RadioGroupComponent.new(
      name: "terms_acceptance",
      label: "Do you accept our terms?",
      options: [
        [ "Yes, I accept the terms and conditions", "yes" ],
        [ "No, I decline", "no" ]
      ],
      required: true
    ))
  end

  # @label With Error
  # @note
  #   Error state applies to the entire group and displays below all options.
  def with_error
    render(Form::Field::RadioGroupComponent.new(
      name: "plan",
      label: "Select a plan",
      options: [ "Basic", "Pro", "Enterprise" ],
      error: "Please select a plan to continue"
    ))
  end

  # @label With Multiple Errors
  # @note
  #   Multiple error messages are joined with commas.
  def with_multiple_errors
    render(Form::Field::RadioGroupComponent.new(
      name: "plan",
      label: "Subscription Plan",
      options: [ "Basic", "Pro" ],
      error: [ "is required", "must be selected to continue" ]
    ))
  end

  # @label Disabled State
  # @note
  #   Disabled groups cannot be interacted with.
  def disabled
    render(Form::Field::RadioGroupComponent.new(
      name: "locked_plan",
      label: "Your Current Plan (Locked)",
      options: [
        [ "Legacy Plan (Grandfathered)", "legacy" ],
        [ "Current Plan", "current" ]
      ],
      value: "legacy",
      disabled: true
    ))
  end

  # @label Small Size
  # @note
  #   Compact size for dense layouts or secondary choices.
  def small_size
    render(Form::Field::RadioGroupComponent.new(
      name: "priority",
      label: "Priority Level",
      options: [ "Low", "Medium", "High", "Critical" ],
      size: :small
    ))
  end

  # @label Medium Size
  # @note
  #   Default size suitable for most forms.
  def medium_size
    render(Form::Field::RadioGroupComponent.new(
      name: "priority",
      label: "Priority Level",
      options: [ "Low", "Medium", "High", "Critical" ],
      size: :medium
    ))
  end

  # @label Large Size
  # @note
  #   Large size for prominent choices or touch-friendly interfaces.
  def large_size
    render(Form::Field::RadioGroupComponent.new(
      name: "priority",
      label: "Priority Level",
      options: [ "Low", "Medium", "High", "Critical" ],
      size: :large
    ))
  end

  # @label All Sizes
  # @note
  #   Comparison of all available sizes side by side.
  def all_sizes
    render_with_template
  end

  # @label Inline Layout
  # @note
  #   Inline layout displays options horizontally with flex-wrap.
  #   Best for short option lists with brief labels.
  def inline_layout
    render(Form::Field::RadioGroupComponent.new(
      name: "size",
      label: "Select Size",
      options: [ "XS", "S", "M", "L", "XL", "XXL" ],
      layout: :inline
    ))
  end

  # @label Stacked Layout
  # @note
  #   Stacked layout displays options vertically (default).
  #   Best for longer option lists or detailed labels.
  def stacked_layout
    render(Form::Field::RadioGroupComponent.new(
      name: "plan",
      label: "Choose your plan",
      options: [
        [ "Free - Basic features only", "free" ],
        [ "Pro - $19/month - All features", "pro" ],
        [ "Team - $49/month - Everything + collaboration", "team" ],
        [ "Enterprise - Custom pricing - Dedicated support", "enterprise" ]
      ],
      layout: :stacked
    ))
  end

  # @label With Data Attributes
  # @note
  #   Custom data attributes for Stimulus controllers and actions.
  def with_data_attributes
    render(Form::Field::RadioGroupComponent.new(
      name: "theme",
      label: "Theme",
      options: [ "Light", "Dark", "Auto" ],
      data: {
        controller: "theme-switcher",
        action: "change->theme-switcher#update"
      }
    ))
  end

  # @label Complete Example
  # @note
  #   A complete example showing label, hint, selected value, and required indicator.
  def complete_example
    render(Form::Field::RadioGroupComponent.new(
      name: "billing_cycle",
      label: "Select Billing Cycle",
      options: [
        [ "Monthly - $29/month", "monthly" ],
        [ "Annual - $278/year", "annual" ]
      ],
      value: "annual",
      hint: "Save 20% with annual billing. You'll be charged once per year.",
      required: true
    ))
  end

  # @label Form Context
  # @note
  #   Example showing radio groups in a complete form context.
  def form_context
    render_with_template
  end
end
